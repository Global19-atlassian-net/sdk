// Copyright (c) 2018, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

/// This library exports all API from Kernel's ast.dart that can be used
/// throughout fasta.
library fasta.kernel_ast_api;

export 'package:kernel/ast.dart'
    show
        AssertStatement,
        AsyncMarker,
        Block,
        BreakStatement,
        Catch,
        CheckLibraryIsLoaded,
        Class,
        ConditionalExpression,
        Constructor,
        ConstructorInvocation,
        ContinueSwitchStatement,
        DartType,
        DynamicType,
        EmptyStatement,
        Expression,
        ExpressionStatement,
        Field,
        FunctionDeclaration,
        FunctionNode,
        FunctionType,
        Initializer,
        InvalidType,
        LabeledStatement,
        Let,
        Library,
        Location,
        Member,
        MethodInvocation,
        Name,
        NamedExpression,
        NamedType,
        Procedure,
        ProcedureKind,
        Rethrow,
        ReturnStatement,
        Statement,
        StaticGet,
        StaticInvocation,
        StringConcatenation,
        SuperInitializer,
        SwitchCase,
        ThisExpression,
        Throw,
        TreeNode,
        TypeParameter,
        TypeParameterType,
        VariableDeclaration,
        VariableGet,
        VoidType,
        setParents;

export 'kernel_shadow_ast.dart'
    show
        ShadowAssertInitializer,
        ShadowAssertStatement,
        ShadowBlock,
        ShadowBreakStatement,
        ShadowCascadeExpression,
        ShadowComplexAssignment,
        ShadowConstructorInvocation,
        ShadowContinueSwitchStatement,
        ShadowDeferredCheck,
        ShadowDoStatement,
        ShadowExpressionStatement,
        ShadowFactoryConstructorInvocation,
        ShadowFieldInitializer,
        ShadowForInStatement,
        ShadowForStatement,
        ShadowFunctionDeclaration,
        ShadowFunctionExpression,
        ShadowIfNullExpression,
        ShadowIfStatement,
        ShadowIllegalAssignment,
        ShadowIndexAssign,
        ShadowInvalidInitializer,
        ShadowIsNotExpression,
        ShadowLabeledStatement,
        ShadowLogicalExpression,
        ShadowLoopAssignmentStatement,
        ShadowMethodInvocation,
        ShadowNamedFunctionExpression,
        ShadowNullAwareMethodInvocation,
        ShadowPropertyAssign,
        ShadowRedirectingInitializer,
        ShadowRethrow,
        ShadowReturnStatement,
        ShadowStaticAssignment,
        ShadowStaticGet,
        ShadowStaticInvocation,
        ShadowSuperInitializer,
        ShadowSuperMethodInvocation,
        ShadowSuperPropertyGet,
        ShadowSwitchStatement,
        ShadowSyntheticExpression,
        ShadowThrow,
        ShadowTryCatch,
        ShadowTryFinally,
        ShadowVariableAssignment,
        ShadowVariableDeclaration,
        ShadowVariableGet,
        ShadowWhileStatement,
        ShadowYieldStatement;
