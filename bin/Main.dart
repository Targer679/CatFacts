import 'dart:convert';
import 'dart:io';

void main() async {
  try {
    final app = CatFactsApp();
    await app.run();
  } catch (e) {
    print('Fatal error in the application: $e');
    exit(1);
  }
}

class CatFactsApp {
  final List<String> _favoriteFacts = [];
  final Map<int, String> _languageCodes = {
    1: 'en',
    2: 'es',
    3: 'fr',
    4: 'de',
    5: 'it',
  };

  void _printHeader() {
    print('\n=== CAT FACTS APP ===\n');
  }

  void _printExitMessage() {
    print('\nThank you for using the Cat Facts App. Goodbye!');
  }

  Future<void> run() async {
    _printHeader();
    bool keepRunning = true;

    while (keepRunning) {
      final languageCode = _getLanguageSelection();
      if (languageCode == 'exit') {
        keepRunning = false;
        break;
      }

      bool stayInLanguage = true;
      while (stayInLanguage) {
        final fact = await _fetchCatFact(languageCode);

        if (fact == null) {
          print(
            '\nUnable to fetch a cat fact. Returning to language selection.\n',
          );
          break;
        }

        _displayFact(fact);
        stayInLanguage = _processFactOptions(fact);
      }
    }

    _printExitMessage();
  }

  String _getLanguageSelection() {
    print('Select language for cat facts:');
    print('1. English');
    print('2. Spanish');
    print('3. French');
    print('4. German');
    print('5. Italian');
    print('0. Exit application');

    stdout.write('\nEnter your choice: ');
    final input = stdin.readLineSync();

    final choice = int.tryParse(input ?? '') ?? -1;
    if (choice == 0) return 'exit';

    if (_languageCodes.containsKey(choice)) {
      return _languageCodes[choice]!;
    } else {
      print('Invalid input. Defaulting to English.\n');
      return 'en';
    }
  }

  Future<String?> _fetchCatFact(String languageCode) async {
    final client = HttpClient();
    try {
      client.connectionTimeout = Duration(seconds: 10);
      final request = await client.getUrl(
        Uri.parse('https://catfact.ninja/fact'),
      );
      request.headers.add('Accept-Language', languageCode);
      final response = await request.close();

      if (response.statusCode == 200) {
        final responseBody = await response.transform(utf8.decoder).join();
        final jsonData = jsonDecode(responseBody);
        return jsonData['fact'];
      } else {
        print('Server error: HTTP ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Network error: $e');
      return 'Cats have five toes on their front paws, but only four on the back. (Fallback)';
    } finally {
      client.close();
    }
  }

  void _displayFact(String fact) {
    print('\n=== CAT FACT ===');
    print(fact);
    print('==============\n');
  }

  bool _processFactOptions(String fact) {
    print('Options:');
    print('1. Add fact to favorites and show next fact');
    print('2. Show next fact');
    print('3. View favorite facts');
    print('4. Clear favorite facts');
    print('5. Return to language selection');

    stdout.write('\nEnter your choice: ');
    final input = stdin.readLineSync();
    final choice = int.tryParse(input ?? '') ?? -1;

    switch (choice) {
      case 1:
        _addToFavorites(fact);
        return true;
      case 2:
        return true;
      case 3:
        _showFavorites();
        return true;
      case 4:
        _clearFavorites();
        return true;
      case 5:
        return false;
      default:
        print('\nInvalid choice. Showing next fact.\n');
        return true;
    }
  }

  void _addToFavorites(String fact) {
    if (!_favoriteFacts.contains(fact)) {
      _favoriteFacts.add(fact);
      print('\nFact added to favorites!');
    } else {
      print('\nThis fact is already in your favorites!');
    }
  }

  void _showFavorites() {
    if (_favoriteFacts.isEmpty) {
      print('\nYou have no favorite facts yet.');
    } else {
      print('\n=== FAVORITE FACTS ===');
      for (int i = 0; i < _favoriteFacts.length; i++) {
        print('${i + 1}. ${_favoriteFacts[i]}');
      }
      print('=====================\n');
    }

    print('Press Enter to continue...');
    stdin.readLineSync();
  }

  void _clearFavorites() {
    if (_favoriteFacts.isEmpty) {
      print('\nYou have no favorite facts to clear.');
    } else {
      _favoriteFacts.clear();
      print('\nFavorite facts list has been cleared!');
    }
  }
}
