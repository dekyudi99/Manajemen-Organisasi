import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:manajemen_organisasi/models/person.dart';
import 'package:http_parser/http_parser.dart';

class PersonService {
  final String baseUrl = 'https://simobile.singapoly.com/api/trpl/customer-service/2355011003';

  Future<List<Person>> fetchPersons() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = jsonDecode(response.body)['datas'];
        return jsonResponse.map((item) => Person.fromJson(item)).toList();
      } else {
        throw Exception('Failed to load persons (status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching persons: $e');
    }
  }

  Future<Person> fetchPerson(int id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/$id'),
      );

      if (response.statusCode == 200) {
        return Person.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to load person (status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error fetching person: $e');
    }
  }

  Future<bool> deletePerson(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/$id'),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error deleting person: $e');
    }
  }

  Future<Person> createPersonWithImage({
    required String nim,
    required String titleIssues,
    required String descriptionIssues,
    required int rating,
    required File? imageFile,
    required int idDivisionTarget,
    required int idPriority,
  }) async {
    try {
      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl'),
      );

      // Add text fields
      request.fields['title_issues'] = titleIssues;
      request.fields['description_issues'] = descriptionIssues;
      request.fields['rating'] = rating.toString();
      request.fields['id_division_target'] = idDivisionTarget.toString();
      request.fields['id_priority'] = idPriority.toString();

      // Add image file if exists
      if (imageFile != null) {
        var fileStream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();
        
        var multipartFile = http.MultipartFile(
          'image',
          fileStream,
          length,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );
        
        request.files.add(multipartFile);
      }

      // Send request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 201) {
        return Person.fromJson(jsonDecode(responseData));
      } else {
        throw Exception('Failed to create person (status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Error creating person: $e');
    }
  }

  Future<Person> updatePersonWithImage({
    required String idCustomerService,
    required String nim,
    required String titleIssues,
    required String descriptionIssues,
    required int rating,
    required File? imageFile,
    required int idDivisionTarget,
    required int idPriority,
    String? currentImageUrl, // URL gambar yang sudah ada (jika ada)
  }) async {
    try {
      // Buat request multipart
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/$idCustomerService'), // PENTING: pakai ID
      );

      // Isi field teks
      request.fields['nim'] = nim;
      request.fields['title_issues'] = titleIssues;
      request.fields['description_issues'] = descriptionIssues;
      request.fields['rating'] = rating.toString();
      request.fields['id_division_target'] = idDivisionTarget.toString();
      request.fields['id_priority'] = idPriority.toString();

      // Tambahkan file gambar jika ada perubahan
      if (imageFile != null) {
        var fileStream = http.ByteStream(imageFile.openRead());
        var length = await imageFile.length();

        var multipartFile = http.MultipartFile(
          'image',
          fileStream,
          length,
          filename: imageFile.path.split('/').last,
          contentType: MediaType('image', 'jpeg'),
        );

        request.files.add(multipartFile);
      } else if (currentImageUrl != null && currentImageUrl.isNotEmpty) {
        // Jika tidak ada gambar baru, sertakan info gambar lama
        request.fields['existing_image_url'] = currentImageUrl;
      }

      // Kirim request
      var response = await request.send();
      var responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        return Person.fromJson(jsonDecode(responseData));
      } else {
        throw Exception('Gagal memperbarui data (status: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Terjadi kesalahan saat update: $e');
    }
  }
}