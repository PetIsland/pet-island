part of petisland_core.module;

abstract class _KeysCached {
  static const String image_cache = 'image_cached';
}

abstract class DIKeys {
  static const String dio_client = 'dio_client';
  static const String cache_image = 'cache_image';
}

class DevModuleCore extends AbstractModule {
  static const String normal_client = 'normal_client';
  static const String api_client = 'api_client';

  // static const String
  @override
  void init() async {
    bind(LocalStorageService).to(await _buildLocalService());
    bind(normal_client).to(_buildClient());
    bind(api_client).to(_buildApiClient());
    bind(AccountService).to(_buildAccountService());
    bind(DIKeys.cache_image).to(await _buildCacheImage());
  }

  Future<LocalStorageService> _buildLocalService() async {
    final SharedPreferences preferences = await SharedPreferences.getInstance();
    final LocalStorageRepository repository = LocalStorageRepositoryImpl(preferences);
    return LocalStorageServiceImpl(repository);
  }

  FileFetcherResponse _handleErrorCacheImage(dynamic ex, String url) {
    Log.error('XFileCachedManager:: Error load $url, $ex');
    return HttpFileFetcherResponse(null);
  }

  Future<TCacheService> _buildCacheImage() async {
    final Duration conectTimeout = Duration(seconds: 15);
    final Directory directory = await getTemporaryDirectory();
    final FileFetcher httpFileFetcher = (String url, {Map<String, String> headers}) {
      return http
          .get(url)
          .timeout(conectTimeout)
          .then((http.Response reponse) => HttpFileFetcherResponse(reponse))
          .catchError((dynamic ex) => _handleErrorCacheImage(ex, url));
    };

    return TCacheService(
      _KeysCached.image_cache,
      directory,
      maxAgeCacheObject: Duration(days: 60),
      maxNrOfCacheObjects: 500,
      fileFetcher: httpFileFetcher,
    );
  }

  HttpClient _buildClient() {
    final BaseOptions baseOption = BaseOptions(
      baseUrl: Config.getString("api_host"),
      connectTimeout: 15000,
      receiveTimeout: 10000,
      headers: <String, dynamic>{
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      },
    );
    Dio dio = Dio(baseOption);
    return HttpClient.init(dio);
  }

  HttpClient _buildApiClient() {
    final BaseOptions baseOption = BaseOptions(
      baseUrl: Config.getString("api_host"),
      connectTimeout: 15000,
      receiveTimeout: 10000,
      headers: <String, dynamic>{
        HttpHeaders.contentTypeHeader: 'application/x-www-form-urlencoded'
      },
    );
    Dio dio = Dio(baseOption);
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: (DioError ex) => ex,
        onResponse: (Response<dynamic> reponse) => reponse,
      ),
    );
    return HttpClient.init(dio);
  }

  RequestOptions _onRequest(RequestOptions options) {
    final LocalStorageService service = DI.get<LocalStorageService>(LocalStorageService);
    final String token = service.getToken();
    if (token is String) {
      options.headers['x-access-token'] = token;
    } else {
      throw PetApiException(statusCode: PetApiException.no_auth);
    }
    return options;
  }

  AccountService _buildAccountService() {
    final HttpClient client = get<HttpClient>(normal_client);
    final AccountReposity reposity = AccountReposityImpl(client);
    return AccountServiceImpl(reposity);
  }
}
