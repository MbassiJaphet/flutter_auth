import 'package:graphql_flutter/graphql_flutter.dart';

const GCMServerId = "657971854537";
const ParseServerURL = "https://parseapi.back4app.com/";
const ParseApplicationId = "Ic6nN0vWE6CrUFYJ35nNT5vvwskpWX6AuWVeWASU";
const ParseAPIKey = "D24rSpVAoC3O0CSAKIVGmn5sSSpe0eW8R4aTq0FL";
const ParseMasterKey = "rYsptPptgVDPVCLSbt235npD53TjBYXmp46wfeYA";
const ParseClientKey = "lPRuTZz9HF7JhYcTlzr8d9oXkYRmajqxdG2TEiku";
const FirebaseServerToken = "AAAAmTItvMk:APA91bEpWEHjJznjSFWCCokYd4_XjjSyLenN8Y2tey_Ky1Rzr6TnywWG6L5ZKTnmvTnSKIgYlFj1YDXLLHwYf9VqGAJJ_tCOJ-uVhoWQrblE7WMEJxZii707tj4Ppw-xstTew9iM2vom";

class GraphQlConfiguration {
  GraphQLClient clientToQuery({String sessionToken}) {
    var httpLink = HttpLink(
      uri: 'https://parseapi.back4app.com/graphql',
      headers: {
        'X-Parse-Application-Id': ParseApplicationId,
        'X-Parse-Client-Key': ParseClientKey,
        'X-Parse-Master-Key': ParseMasterKey,
      },
    );

    return GraphQLClient(
      cache: OptimisticCache(dataIdFromObject: typenameDataIdFromObject),
      link: httpLink,
    );
  }
}
