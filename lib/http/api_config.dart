class ApiConfig {
  static const baseUrl = 'http://192.168.210.166:4000';

  // 注册
  static const api_register = '/api/auth/register';
  // 登录
  static const api_login = '/api/auth/login';
  // 搭配
  static const api_outfit = '/api/outfit/list';
  // 热门搭配
  static const api_recommendation = '/api/outfit/recommendation';
  // 浏览量
  static const api_update_views = '/api/outfit/updateViews';
  // 新增穿搭
  static const api_outfit_add = '/api/outfit/add';
  // 浏览日期
  static const api_date = '/api/record/date';
  // 浏览历史
  static const api_record = '/api/record/list';
  // 收藏列表
  static const api_favorite_list = '/api/favorite/list';
  // 删除收藏
  static const api_favorite_delete = '/api/favorite/delete';
  // 添加收藏
  static const api_favorite_add = '/api/favorite/add';

  static const connectTimeout = 3;
  static const receiveTimeout = 3;
  static const successCode = 200;
}
