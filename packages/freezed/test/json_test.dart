// ignore_for_file: prefer_const_constructors, omit_local_variable_types
import 'package:analyzer/dart/analysis/results.dart';
import 'package:build_test/build_test.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:matcher/matcher.dart';
import 'package:test/test.dart';

import 'common.dart';
import 'integration/json.dart';

Future<void> main() async {
  final jsonFile = await resolveSources(
    {'freezed|test/integration/json.dart': useAssetReader},
    (r) => r.libraries
        .firstWhere((element) => element.source.toString().contains('json')),
  );

  test('can have a custom fromJson', () {
    expect(
      Regression280.fromJson(<String, String>{'foo': 'value'}),
      Regression280('value'),
    );
    expect(
      Regression280n2.fromJson('hello'),
      Regression280n2('hello'),
    );

    expect(
      jsonFile.topLevelElements.any((e) => e.name == r'_$Regresssion280'),
      isFalse,
    );
    expect(
      jsonFile.topLevelElements.any((e) => e.name == r'_$Regresssion280n2'),
      isFalse,
    );
  });

  test('custom fromJson + json_serializable', () {
    expect(
      CustomJson.fromJson(<String, dynamic>{'key': 'value'}),
      CustomJson('value'),
    );
  });

  group('Freezed.unionKey', () {
    test('fromJson', () {
      expect(
        CustomKey.fromJson(<String, dynamic>{'type': 'first', 'a': 42}),
        CustomKey.first(42),
      );

      expect(
        CustomKey.fromJson(<String, dynamic>{'type': 'second', 'a': 21}),
        CustomKey.second(21),
      );

      expect(
        RawCustomKey.fromJson(<String, dynamic>{'\$type': 'first', 'a': 42}),
        RawCustomKey.first(42),
      );

      expect(
        FancyCustomKey.fromJson(<String, dynamic>{'ty"\'pe': 'first', 'a': 42}),
        FancyCustomKey.first(42),
      );
    });

    test('toJson', () {
      expect(
        CustomKey.first(42).toJson(),
        <String, dynamic>{'type': 'first', 'a': 42},
      );

      expect(
        CustomKey.second(21).toJson(),
        <String, dynamic>{'type': 'second', 'a': 21},
      );

      expect(
        RawCustomKey.first(42).toJson(),
        <String, dynamic>{'\$type': 'first', 'a': 42},
      );

      expect(
        FancyCustomKey.first(42).toJson(),
        <String, dynamic>{'ty"\'pe': 'first', 'a': 42},
      );
    });
  });

  group('FreezedUnionValue', () {
    test('fromJson', () {
      expect(
        CustomUnionValue.fromJson(<String, dynamic>{
          'runtimeType': 'first',
          'a': 42,
        }),
        CustomUnionValue.first(42),
      );

      expect(
        CustomUnionValue.fromJson(<String, dynamic>{
          'runtimeType': 'SECOND',
          'a': 21,
        }),
        CustomUnionValue.second(21),
      );
    });

    test('toJson', () {
      expect(
        CustomUnionValue.first(42).toJson(),
        <String, dynamic>{'runtimeType': 'first', 'a': 42},
      );

      expect(
        CustomUnionValue.second(21).toJson(),
        <String, dynamic>{'runtimeType': 'SECOND', 'a': 21},
      );
    });
  });

  group('FreezedUnionFallback', () {
    test(
        'when fallback is non-null, if fromJson receives null as value, fallbacks to default',
        () {
      expect(
        UnionFallback.fromJson(<String, dynamic>{'type': null, 'a': 42}),
        UnionFallback.fallback(42),
      );
      expect(
        UnionFallback.fromJson(<String, dynamic>{'a': 42}),
        UnionFallback.fallback(42),
      );
    });

    test('fromJson', () {
      expect(
        UnionFallback.fromJson(<String, dynamic>{
          'runtimeType': 'first',
          'a': 42,
        }),
        UnionFallback.first(42),
      );

      expect(
        UnionFallback.fromJson(<String, dynamic>{
          'runtimeType': 'second',
          'a': 21,
        }),
        UnionFallback.second(21),
      );

      expect(
        UnionFallback.fromJson(<String, dynamic>{
          'runtimeType': 'third',
          'a': 10,
        }),
        UnionFallback.fallback(10),
      );

      expect(
        UnionFallback.fromJson(<String, dynamic>{
          'a': 55,
        }),
        UnionFallback.fallback(55),
      );

      final invalidUnionTypeValueJson = <String, dynamic>{
        'runtimeType': 'third',
        'a': 10,
      };
      expect(
        () => CustomUnionValue.fromJson(invalidUnionTypeValueJson),
        throwsA(
          isA<CheckedFromJsonException>()
              .having((e) => e.key, 'key', 'runtimeType')
              .having((e) => e.map, 'map', invalidUnionTypeValueJson)
              .having((e) => e.className, 'className', 'CustomUnionValue'),
        ),
      );
    });
  });

  group('FreezedUnionFallback default', () {
    test('fromJson', () {
      expect(
        UnionDefaultFallback.fromJson(<String, dynamic>{
          'runtimeType': 'first',
          'a': 42,
        }),
        UnionDefaultFallback.first(42),
      );

      expect(
        UnionDefaultFallback.fromJson(<String, dynamic>{
          'runtimeType': 'third',
          'a': 10,
        }),
        UnionDefaultFallback(10),
      );

      expect(
        UnionDefaultFallback.fromJson(<String, dynamic>{
          'a': 55,
        }),
        UnionDefaultFallback(55),
      );
    });
  });

  group('Freezed.unionValueCase', () {
    test('FreezedUnionCase.pascal fromJson', () {
      expect(
        UnionValueCasePascal.fromJson(<String, dynamic>{
          'runtimeType': 'First',
          'a': 42,
        }),
        UnionValueCasePascal.first(42),
      );

      expect(
        UnionValueCasePascal.fromJson(<String, dynamic>{
          'runtimeType': 'SecondValue',
          'a': 21,
        }),
        UnionValueCasePascal.secondValue(21),
      );
    });

    test('FreezedUnionCase.pascal toJson', () {
      expect(
        UnionValueCasePascal.first(42).toJson(),
        <String, dynamic>{'runtimeType': 'First', 'a': 42},
      );

      expect(
        UnionValueCasePascal.secondValue(21).toJson(),
        <String, dynamic>{'runtimeType': 'SecondValue', 'a': 21},
      );
    });

    test('FreezedUnionCase.kebab fromJson', () {
      expect(
        UnionValueCaseKebab.fromJson(<String, dynamic>{
          'runtimeType': 'first',
          'a': 42,
        }),
        UnionValueCaseKebab.first(42),
      );

      expect(
        UnionValueCaseKebab.fromJson(<String, dynamic>{
          'runtimeType': 'second-value',
          'a': 21,
        }),
        UnionValueCaseKebab.secondValue(21),
      );
    });

    test('FreezedUnionCase.kebab toJson', () {
      expect(
        UnionValueCaseKebab.first(42).toJson(),
        <String, dynamic>{'runtimeType': 'first', 'a': 42},
      );

      expect(
        UnionValueCaseKebab.secondValue(21).toJson(),
        <String, dynamic>{'runtimeType': 'second-value', 'a': 21},
      );
    });

    test('FreezedUnionCase.snake fromJson', () {
      expect(
        UnionValueCaseSnake.fromJson(<String, dynamic>{
          'runtimeType': 'first',
          'a': 42,
        }),
        UnionValueCaseSnake.first(42),
      );

      expect(
        UnionValueCaseSnake.fromJson(<String, dynamic>{
          'runtimeType': 'second_value',
          'a': 21,
        }),
        UnionValueCaseSnake.secondValue(21),
      );
    });

    test('FreezedUnionCase.snake toJson', () {
      expect(
        UnionValueCaseSnake.first(42).toJson(),
        <String, dynamic>{'runtimeType': 'first', 'a': 42},
      );

      expect(
        UnionValueCaseSnake.secondValue(21).toJson(),
        <String, dynamic>{'runtimeType': 'second_value', 'a': 21},
      );
    });
  });

  test('class decorators are applied on the generated class', () {
    expect(
      ClassDecorator('Complex name').toJson(),
      {
        'complex_name': 'Complex name',
      },
    );
  });

  test('@Default implies a @JsonKey', () {
    final value = DefaultValue();
    expect(
      value.toJson(),
      {'value': 42},
    );

    expect(
      DefaultValue.fromJson(<String, dynamic>{}),
      DefaultValue(42),
    );
  });

  test('@Default does not imply a @JsonKey if one is already specified', () {
    expect(
      DefaultValueJsonKey.fromJson(<String, dynamic>{}),
      DefaultValueJsonKey(21),
    );
  });

  group('generic json', () {
    test('fromJson', () {
      expect(
        Generic<int>.fromJson(<String, dynamic>{'a': 42}),
        Generic(42),
      );
    });

    test('tear-off', () {
      Generic<int> Function(Map<String, Object?>) fromJson = $Generic.fromJson;

      expect(
        fromJson(<String, dynamic>{'a': 42}),
        Generic(42),
      );
    });
  });

  test('single ctor + json can access properties/copyWith', () {
    final value = Single(42);

    expect(value.a, 42);
    expect(value.copyWith(a: 24), Single(24));
  });

  test('has no issue', () async {
    var errorResult = await jsonFile.session
            .getErrors('/freezed/test/integration/json.freezed.dart')
        as ErrorsResult;
    expect(errorResult.errors, isEmpty);
  }, skip: true);

  test("single constructor fromJson doesn't require runtimeType", () {
    expect(
      Single.fromJson(<String, dynamic>{
        'a': 42,
      }),
      Single(42),
    );
  });

  test("single constructor toJson doesn't add runtimeType", () {
    expect(
      Single(42).toJson(),
      {
        'a': 42,
      },
    );
  });

  group('toJson', () {
    test('support JsonKeys', () {
      expect(Decorator('42').toJson(), {'what': '42'});
    });

    test('works', () {
      expect(
        Json().toJson(),
        {
          'runtimeType': 'default',
        },
      );

      expect(
        Json.first('42').toJson(),
        {
          'a': '42',
          'runtimeType': 'first',
        },
      );

      expect(
        Json.second(42).toJson(),
        {
          'b': 42,
          'runtimeType': 'second',
        },
      );
    });
  });

  test('throws if runtimeType matches nothing', () {
    const emptyJson = <String, dynamic>{};
    expect(
      () => Json.fromJson(emptyJson),
      throwsA(
        isA<CheckedFromJsonException>()
            .having((e) => e.key, 'key', 'runtimeType')
            .having((e) => e.map, 'map', emptyJson)
            .having((e) => e.className, 'className', 'Json'),
      ),
    );

    const unknownTypeJson = <String, dynamic>{'runtimeType': 'unknown'};
    expect(
      () => Json.fromJson(unknownTypeJson),
      throwsA(
        isA<CheckedFromJsonException>()
            .having((e) => e.key, 'key', 'runtimeType')
            .having((e) => e.map, 'map', unknownTypeJson)
            .having((e) => e.className, 'className', 'Json'),
      ),
    );
  });

  test('fromJson', () {
    expect(
      Json.fromJson(<String, dynamic>{
        'runtimeType': 'default',
      }),
      Json(),
    );

    expect(
      Json.fromJson(<String, dynamic>{
        'runtimeType': 'first',
        'a': '42',
      }),
      Json.first('42'),
    );

    expect(
      Json.fromJson(<String, dynamic>{
        'runtimeType': 'second',
        'b': 42,
      }),
      Json.second(42),
    );
  });

  test('if no fromJson exists, no constructors are made', () async {
    await expectLater(compile(r'''
import 'json.dart';

void main() {
  Json.fromJson(<String, dynamic>{});
}
'''), completes);

    await expectLater(compile(r'''
import 'json.dart';

void main() {
  NoFirst.fromJson(<String, dynamic>{});
}
'''), throwsCompileError);

    await expectLater(compile(r'''
import 'json.dart';

void main() {
  NoDefault.fromJson(<String, dynamic>{});
}
'''), throwsCompileError);

    await expectLater(compile(r'''
import 'json.dart';

void main() {
  NoSecond.fromJson(<String, dynamic>{});
}
'''), throwsCompileError);
  });
}
