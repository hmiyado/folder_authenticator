import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:totp_folder/home/home_page_providers.dart';
import 'package:totp_folder/models/totp_entry.dart';
import 'package:totp_folder/repositories/totp_entry_repository.dart';

@GenerateNiceMocks([MockSpec<TotpEntryRepository>()])
import 'home_page_providers_test.mocks.dart';

void main() {
  late ProviderContainer container;
  late MockTotpEntryRepository mockTotpEntryRepository;

  setUp(() {
    mockTotpEntryRepository = MockTotpEntryRepository();

    // Create a ProviderContainer with overrides
    container = ProviderContainer(
      overrides: [
        // Override the totpEntryRepositoryProvider to return our mock
        totpEntryRepositoryProvider.overrideWithValue(mockTotpEntryRepository),
      ],
    );

    // Add a listener to the container to make sure providers are properly disposed
    addTearDown(container.dispose);
  });

  group('Home Page Providers', () {
    test('createTotpEntry should update totpEntriesByFolder', () async {
      // Test data
      final totpEntry = TotpEntry(
        id: 1,
        name: 'Existing Entry 1',
        secret: 'SECRET1',
        issuer: 'Issuer 1',
        folderId: 1,
      );
      const int newEntryId = 2;

      when(
        mockTotpEntryRepository.createTotpEntry(any, any, any, any),
      ).thenAnswer((_) async => newEntryId);

      // Act - create a new entry
      container.read(
        createTotpEntryProvider(
          totpEntry.folderId,
          totpEntry.name,
          totpEntry.secret,
          totpEntry.issuer,
        ),
      );

      verify(
        mockTotpEntryRepository.createTotpEntry(
          totpEntry.name,
          totpEntry.secret,
          totpEntry.issuer,
          totpEntry.folderId,
        ),
      );
    });
  });
}
