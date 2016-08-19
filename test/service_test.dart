library service_test;

import 'dart:async' show Future;

import 'package:protobuf/protobuf.dart';
import 'package:test/test.dart';

import '../out/protos/service.pbserver.dart' as pb;
import '../out/protos/service2.pb.dart' as pb2;
import '../out/protos/service3.pb.dart' as pb3;

import '../out/protos/descriptor_2_5_opensource.pb.dart'
    show DescriptorProto, ServiceDescriptorProto;

class SearchService extends pb.SearchServiceBase {
  Future<pb.SearchResponse> search(
      ServerContext ctx, pb.SearchRequest request) async {
    var out = new pb.SearchResponse();
    if (request.query == 'hello' || request.query == 'world') {
      out.result.add('hello, world!');
    }
    return out;
  }

  Future<pb2.SearchResponse> search2(
      ServerContext ctx, pb2.SearchRequest request) async {
    var out = new pb2.SearchResponse();
    if (request.query == '2') {
      var result = new pb3.SearchResult()
        ..url = 'http://example.com/'
        ..snippet = 'hello world (2)!';
      out.results.add(result);
    }
    return out;
  }
}

class FakeJsonServer {
  final GeneratedService searchService;
  FakeJsonServer(this.searchService);

  Future<String> messageHandler(
      String serviceName, String methodName, String requestJson) async {
    if (serviceName == 'SearchService') {
      GeneratedMessage request = searchService.createRequest(methodName);
      request.mergeFromJson(requestJson);
      var ctx = new ServerContext();
      var reply = await searchService.handleCall(ctx, methodName, request);
      return reply.writeToJson();
    } else {
      throw 'unknown service: $serviceName';
    }
  }
}

class FakeJsonClient implements RpcClient {
  final FakeJsonServer server;
  FakeJsonClient(this.server);

  Future<GeneratedMessage> invoke(
      ClientContext ctx,
      String serviceName,
      String methodName,
      GeneratedMessage request,
      GeneratedMessage response) async {
    String requestJson = request.writeToJson();
    String replyJson =
        await server.messageHandler(serviceName, methodName, requestJson);
    response.mergeFromJson(replyJson);
    return response;
  }
}

void main() {
  var service = new SearchService();
  var server = new FakeJsonServer(service);
  var api = new pb.SearchServiceApi(new FakeJsonClient(server));

  test('end to end RPC using JSON', () async {
    var request = new pb.SearchRequest()..query = 'hello';
    var reply = await api.search(new ClientContext(), request);
    expect(reply.result, ['hello, world!']);
  });

  test('end to end RPC using message from a different package', () async {
    var request = new pb2.SearchRequest()..query = "2";
    var reply = await api.search2(new ClientContext(), request);
    expect(reply.results.length, 1);
    expect(reply.results[0].url, 'http://example.com/');
    expect(reply.results[0].snippet, 'hello world (2)!');
  });

  test('can read service descriptor from JSON', () {
    var descriptor = new ServiceDescriptorProto()
      ..mergeFromJsonMap(service.$json);
    expect(descriptor.name, "SearchService");
    var methodNames = descriptor.method.map((m) => m.name).toList();
    expect(methodNames, ["Search", "Search2"]);
  });

  test('can read message descriptors from JSON', () {
    var map = service.$messageJson;
    expect(map.keys, [
      '.SearchRequest',
      '.SearchResponse',
      '.service2.SearchRequest',
      '.service2.SearchResponse',
      '.service3.SearchResult',
    ]);

    String readMessageName(fqname) {
      var json = map[fqname] as Map<String, dynamic>;
      var descriptor = new DescriptorProto()..mergeFromJsonMap(json);
      return descriptor.name;
    }

    expect(readMessageName('.SearchRequest'), "SearchRequest");
    expect(readMessageName('.service2.SearchRequest'), "SearchRequest");
    expect(readMessageName('.service3.SearchResult'), "SearchResult");
  });
}
