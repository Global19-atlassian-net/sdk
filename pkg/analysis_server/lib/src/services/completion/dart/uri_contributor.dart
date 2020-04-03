// Copyright (c) 2014, the Dart project authors. Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import 'dart:async';
import 'dart:core';

import 'package:analysis_server/src/protocol_server.dart'
    show CompletionSuggestion, CompletionSuggestionKind;
import 'package:analysis_server/src/provisional/completion/dart/completion_dart.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/file_system/file_system.dart';
import 'package:path/path.dart' show posix;

/// A contributor that produces suggestions based on the content of the file
/// system to complete within URIs in import, export and part directives.
class UriContributor extends DartCompletionContributor {
  /// A flag indicating whether file: and package: URI suggestions should
  /// be included in the list of completion suggestions.
  // TODO(danrubel): remove this flag and related functionality
  // once the UriContributor limits file: and package: URI suggestions
  // to only those paths within context roots.
  static bool suggestFilePaths = true;

  @override
  Future<List<CompletionSuggestion>> computeSuggestions(
      DartCompletionRequest request) async {
    var builder = _UriSuggestionBuilder(request);
    request.target.containingNode.accept(builder);
    return builder.suggestions;
  }
}

class _UriSuggestionBuilder extends SimpleAstVisitor<void> {
  // TODO(brianwilkerson) Consider whether to make these constants in
  //  Relevance (after renaming them).
  static const int dartCoreRelevance = 100;
  static const int defaultRelevance = 900;

  final DartCompletionRequest request;

  final List<CompletionSuggestion> suggestions = <CompletionSuggestion>[];

  _UriSuggestionBuilder(this.request);

  @override
  void visitExportDirective(ExportDirective node) {
    visitNamespaceDirective(node);
  }

  @override
  void visitImportDirective(ImportDirective node) {
    visitNamespaceDirective(node);
  }

  void visitNamespaceDirective(NamespaceDirective node) {
    var uri = node.uri;
    if (uri is SimpleStringLiteral) {
      var offset = request.offset;
      var start = uri.offset;
      var end = uri.end;
      if (offset > start) {
        if (offset < end) {
          // Quoted non-empty string
          visitSimpleStringLiteral(uri);
        } else if (offset == end) {
          if (end == start + 1) {
            // Quoted empty string
            visitSimpleStringLiteral(uri);
          } else {
            var data = request.sourceContents;
            if (end == data.length) {
              var ch = data[end - 1];
              if (ch != '"' && ch != "'") {
                // Insertion point at end of file
                // and missing closing quote on non-empty string
                visitSimpleStringLiteral(uri);
              }
            }
          }
        }
      } else if (offset == start && offset == end) {
        var data = request.sourceContents;
        if (end == data.length) {
          var ch = data[end - 1];
          if (ch == '"' || ch == "'") {
            // Insertion point at end of file
            // and missing closing quote on empty string
            visitSimpleStringLiteral(uri);
          }
        }
      }
    }
  }

  @override
  void visitSimpleStringLiteral(SimpleStringLiteral node) {
    var parent = node.parent;
    if (parent is NamespaceDirective && parent.uri == node) {
      var partialUri = _extractPartialUri(node);
      if (partialUri != null) {
        _addDartSuggestions();
        if (UriContributor.suggestFilePaths) {
          _addPackageSuggestions(partialUri);
          _addFileSuggestions(partialUri);
        }
      }
    } else if (parent is PartDirective && parent.uri == node) {
      var partialUri = _extractPartialUri(node);
      if (partialUri != null) {
        if (UriContributor.suggestFilePaths) {
          _addFileSuggestions(partialUri);
        }
      }
    }
  }

  void _addDartSuggestions() {
    _addSuggestion('dart:');
    var factory = request.sourceFactory;
    for (var lib in factory.dartSdk.sdkLibraries) {
      if (!lib.isInternal && !lib.isImplementation) {
        if (!lib.shortName.startsWith('dart:_')) {
          int relevance;
          if (request.useNewRelevance) {
            relevance = lib.shortName == 'dart:core'
                ? dartCoreRelevance
                : defaultRelevance;
          } else {
            relevance = lib.shortName == 'dart:core'
                ? DART_RELEVANCE_LOW
                : DART_RELEVANCE_DEFAULT;
          }
          _addSuggestion(lib.shortName, relevance: relevance);
        }
      }
    }
  }

  void _addFileSuggestions(String partialUri) {
    var resProvider = request.resourceProvider;
    var resContext = resProvider.pathContext;
    var source = request.source;

    String parentUri;
    if ((partialUri.endsWith('/'))) {
      parentUri = partialUri;
    } else {
      parentUri = posix.dirname(partialUri);
      if (parentUri != '.' && !parentUri.endsWith('/')) {
        parentUri = '$parentUri/';
      }
    }
    var uriPrefix = parentUri == '.' ? '' : parentUri;

    // Only handle file uris in the format file:///xxx or /xxx
    var parentUriScheme = Uri.parse(parentUri).scheme;
    if (!parentUri.startsWith('file://') && parentUriScheme != '') {
      return;
    }

    var dirPath = resProvider.pathContext.fromUri(parentUri);
    dirPath = resContext.normalize(dirPath);

    if (resContext.isRelative(dirPath)) {
      var sourceDirPath = resContext.dirname(source.fullName);
      if (resContext.isAbsolute(sourceDirPath)) {
        dirPath = resContext.normalize(resContext.join(sourceDirPath, dirPath));
      } else {
        return;
      }
      // Do not suggest relative paths reaching outside the 'lib' directory.
      var srcInLib = resContext.split(sourceDirPath).contains('lib');
      var dstInLib = resContext.split(dirPath).contains('lib');
      if (srcInLib && !dstInLib) {
        return;
      }
    }
    if (dirPath.endsWith('\\.')) {
      dirPath = dirPath.substring(0, dirPath.length - 1);
    }

    var dir = resProvider.getResource(dirPath);
    if (dir is Folder) {
      try {
        for (var child in dir.getChildren()) {
          String completion;
          if (child is Folder) {
            if (!child.shortName.startsWith('.')) {
              completion = '$uriPrefix${child.shortName}/';
            }
          } else if (child is File) {
            if (child.shortName.endsWith('.dart')) {
              completion = '$uriPrefix${child.shortName}';
            }
          }
          if (completion != null && completion != source.shortName) {
            _addSuggestion(completion);
          }
        }
      } on FileSystemException {
        // Guard against I/O exceptions.
      }
    }
  }

  void _addPackageFolderSuggestions(
      String partial, String prefix, Folder folder) {
    try {
      for (var child in folder.getChildren()) {
        if (child is Folder) {
          var childPrefix = '$prefix${child.shortName}/';
          _addSuggestion(childPrefix);
          if (partial.startsWith(childPrefix)) {
            _addPackageFolderSuggestions(partial, childPrefix, child);
          }
        } else {
          _addSuggestion('$prefix${child.shortName}');
        }
      }
    } on FileSystemException {
      // Guard against I/O exceptions.
      return;
    }
  }

  void _addPackageSuggestions(String partial) {
    var factory = request.sourceFactory;
    var packageMap = factory.packageMap;
    if (packageMap != null) {
      _addSuggestion('package:');
      packageMap.forEach((pkgName, folders) {
        var prefix = 'package:$pkgName/';
        _addSuggestion(prefix);
        for (var folder in folders) {
          if (folder.exists) {
            _addPackageFolderSuggestions(partial, prefix, folder);
          }
        }
      });
    }
  }

  void _addSuggestion(String completion, {int relevance}) {
    if (request.useNewRelevance) {
      relevance ??= defaultRelevance;
    } else {
      relevance ??= DART_RELEVANCE_DEFAULT;
    }
    suggestions.add(CompletionSuggestion(CompletionSuggestionKind.IMPORT,
        relevance, completion, completion.length, 0, false, false));
  }

  String _extractPartialUri(SimpleStringLiteral node) {
    if (request.offset < node.contentsOffset) {
      return null;
    }
    return node.literal.lexeme.substring(
        node.contentsOffset - node.offset, request.offset - node.offset);
  }
}
