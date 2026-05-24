import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class CardScanResult {
  final String? fullName;
  final String? designation;
  final String? company;
  final String? phone1;
  final String? phone2;
  final String? phone3;
  final String? email1;
  final String? email2;
  final String? website;
  final String? address;
  final String? linkedin;
  final String? twitter;
  final String? instagram;
  final String? facebook;
  final String? whatsapp;

  CardScanResult({
    this.fullName,
    this.designation,
    this.company,
    this.phone1,
    this.phone2,
    this.phone3,
    this.email1,
    this.email2,
    this.website,
    this.address,
    this.linkedin,
    this.twitter,
    this.instagram,
    this.facebook,
    this.whatsapp,
  });
}

class CardScannerHelper {
  static final _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  static Future<CardScanResult> scanCard(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognized = await _recognizer.processImage(inputImage);
    final text = recognized.text;
    final lines = text.split('\n').map((l) => l.trim()).where((l) => l.isNotEmpty).toList();
    return _extractFields(lines, text);
  }

  static CardScanResult _extractFields(List<String> lines, String fullText) {
    // --- Regex patterns ---
    final emailRegex = RegExp(r'[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}');
    final phoneRegex = RegExp(r'(\+?\d[\d\s\-().]{7,}\d)');
    final urlRegex = RegExp(r'(https?://[^\s]+|www\.[^\s]+|[a-zA-Z0-9\-]+\.[a-zA-Z]{2,}(?:/[^\s]*)?)');
    final linkedinRegex = RegExp(r'linkedin\.com/in/([^\s/]+)', caseSensitive: false);
    final twitterRegex = RegExp(r'(?:twitter\.com/|x\.com/|@)([a-zA-Z0-9_]+)');
    final instaRegex = RegExp(r'(?:instagram\.com/|ig:|insta:)\s*([a-zA-Z0-9_.]+)', caseSensitive: false);
    final fbRegex = RegExp(r'facebook\.com/([^\s/]+)', caseSensitive: false);
    final whatsappRegex = RegExp(r'(?:wa\.me/|whatsapp[:\s]+)(\+?[\d\s\-]{7,})', caseSensitive: false);

    // Designation keywords
    final designationKeywords = [
      'ceo', 'cto', 'coo', 'cfo', 'founder', 'co-founder', 'director', 'manager',
      'engineer', 'developer', 'designer', 'consultant', 'analyst', 'officer',
      'president', 'vp', 'vice president', 'head', 'lead', 'architect', 'executive',
      'associate', 'senior', 'junior', 'intern', 'partner', 'proprietor', 'owner',
    ];

    // --- Extract emails ---
    final emails = emailRegex.allMatches(fullText).map((m) => m.group(0)!).toList();

    // --- Extract phones (exclude years/zip codes) ---
    final rawPhones = phoneRegex.allMatches(fullText).map((m) => m.group(0)!.trim()).toList();
    final phones = rawPhones.where((p) {
      final digits = p.replaceAll(RegExp(r'\D'), '');
      return digits.length >= 7 && digits.length <= 15;
    }).toList();

    // --- Extract social links ---
    String? liResult, twResult, igResult, fbResult, waResult, webResult;

    final linkedinMatch = linkedinRegex.firstMatch(fullText);
    if (linkedinMatch != null) liResult = linkedinMatch.group(1);

    final twitterMatch = twitterRegex.firstMatch(fullText);
    if (twitterMatch != null) twResult = twitterMatch.group(1);

    final instaMatch = instaRegex.firstMatch(fullText);
    if (instaMatch != null) igResult = instaMatch.group(1);

    final fbMatch = fbRegex.firstMatch(fullText);
    if (fbMatch != null) fbResult = fbMatch.group(1);

    final waMatch = whatsappRegex.firstMatch(fullText);
    if (waMatch != null) waResult = waMatch.group(1)?.replaceAll(RegExp(r'\s'), '');

    // --- Extract website (non-social URLs) ---
    final socialDomains = RegExp(r'linkedin|twitter|instagram|facebook|wa\.me|whatsapp', caseSensitive: false);
    for (final m in urlRegex.allMatches(fullText)) {
      final url = m.group(0)!;
      if (!socialDomains.hasMatch(url) && !emailRegex.hasMatch(url)) {
        webResult = url.startsWith('http') ? url : 'https://$url';
        break;
      }
    }

    // --- Classify lines into name / designation / company ---
    String? fullName, designation, company;
    final addressParts = <String>[];

    // Remove lines that are clearly emails, phones, or URLs
    final structuredLines = lines.where((line) {
      return !emailRegex.hasMatch(line) &&
          !phoneRegex.hasMatch(line) &&
          !urlRegex.hasMatch(line);
    }).toList();

    for (final line in structuredLines) {
      final lower = line.toLowerCase();

      // Check if line contains a designation keyword
      if (designation == null && designationKeywords.any((k) => lower.contains(k))) {
        designation = line;
        continue;
      }

      // Heuristic: name is usually the largest/first text, all words capitalized, 2-4 words
      if (fullName == null) {
        final words = line.split(' ').where((w) => w.isNotEmpty).toList();
        final looksLikeName = words.length >= 2 &&
            words.length <= 5 &&
            words.every((w) => w[0] == w[0].toUpperCase()) &&
            !lower.contains(RegExp(r'\d'));
        if (looksLikeName) {
          fullName = line;
          continue;
        }
      }

      // Company: often has Ltd, Pvt, Inc, Corp, LLP, Technologies, Solutions etc.
      if (company == null) {
        final companyKeywords = RegExp(
            r'\b(pvt|ltd|llp|inc|corp|technologies|solutions|services|group|enterprises|associates|consulting)\b',
            caseSensitive: false);
        if (companyKeywords.hasMatch(lower)) {
          company = line;
          continue;
        }
      }

      // Address heuristics: contains digits + road/street/nagar/city keywords or pin codes
      final addressKeywords = RegExp(
          r'\b(road|rd|street|st|nagar|colony|sector|phase|plot|flat|floor|building|near|opp|pin|dist|state|city|town|village|area|lane|avenue|blvd|suite|apt)\b',
          caseSensitive: false);
      if (addressKeywords.hasMatch(lower) || RegExp(r'\b\d{6}\b').hasMatch(line)) {
        addressParts.add(line);
      }
    }

    // If company still not found, take the second non-name structured line
    if (company == null && structuredLines.length > 1) {
      for (final line in structuredLines) {
        if (line != fullName && line != designation) {
          company = line;
          break;
        }
      }
    }

    final address = addressParts.isNotEmpty ? addressParts.join(', ') : null;

    return CardScanResult(
      fullName: fullName,
      designation: designation,
      company: company,
      phone1: phones.isNotEmpty ? phones[0] : null,
      phone2: phones.length > 1 ? phones[1] : null,
      phone3: phones.length > 2 ? phones[2] : null,
      email1: emails.isNotEmpty ? emails[0] : null,
      email2: emails.length > 1 ? emails[1] : null,
      website: webResult,
      address: address,
      linkedin: liResult,
      twitter: twResult,
      instagram: igResult,
      facebook: fbResult,
      whatsapp: waResult,
    );
  }

  static void dispose() => _recognizer.close();
}

