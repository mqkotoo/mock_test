import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mock_test/main.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:http/http.dart' as http;

import 'github_api_repository_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>(),MockSpec<GitHubApiRepository>()])
main() {
  test('mockのテスト', () async {
    final client = MockClient();
    when(client.get(any))
        .thenAnswer((_) async => http.Response('{"total_count":467417}', 200));

    expect(
      (await client.get(Uri.parse(
              'https://api.github.com/search/repositories?q=flutter')))
          .body,
      '{"total_count":467417}',
    );
  });

  test('DIでモックを使用してテスト', () async {
    final client = MockClient();
    when(client.get(any))
        .thenAnswer((_) async => http.Response('{"total_count":467417}', 200));

  //  DI setting
    GetIt.I.registerLazySingleton<http.Client>(() => client);

    //test GitHubApiRepository using mock
    final repository = GitHubApiRepository();
    final result = await repository.countRepositories();
    expect(result,467417);
  });

  testWidgets('WIDGETテストにモックを使う、タップごとに値を変更する', (WidgetTester tester) async{
    final repository = MockGitHubApiRepository();
    final answers = [1,5];

    when(repository.countRepositories())
      .thenAnswer((_) async => answers.removeAt(0));

    GetIt.I.registerLazySingleton<GitHubApiRepository>(() => repository);

    await tester.pumpWidget(const MyApp());
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.text('0'), findsNothing);
    expect(find.text('5'), findsOneWidget);



  });

}
