import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sgem/config/api/api.dart';

void main() {
  group('ApiChinalco', () {
    group('Authorization Header', () {
      const localHost = 'https://localhost:44348';
      const user = r'PC\User';

      test('should set the user', () {
        final auth = 'Basic $user';
        ApiChinalco.dio = ApiChinalco.createDio(
          baseUrl: localHost,
          apiKey: '',
          // Windows user
          user: auth,
        );

        final api = TestApiChinalco();

        expect(ApiChinalco.user, auth);
        expect(api.options.headers['Authorization'], auth);

        // expect response is equal to user
        // expect(api.getTest(), returnsNormally);
      });
    });
  });
}

class TestApiChinalco extends ApiChinalco {
  @override
  String get endpoint => 'api/test';

  // Future<String> getTest() async {
  //   try {
  //     return await get(path: '/test');
  //   } on DioException catch (e) {
  //     throw Exception(e.error);
  //   } catch (e) {
  //     rethrow;
  //   }
  // }
}
