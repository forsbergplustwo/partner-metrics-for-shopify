Rails.application.routes.draw do
  root to: 'home#index'

  post  '/'  => 'home#index'
  post  'import' => 'home#import'
  post  'import_app_history' => 'home#import_app_history'
  get   'recurring' => 'home#recurring'
  get   'onetime' => 'home#onetime'
  get   'affiliate' => 'home#affiliate'
  get   'users' => 'home#users'
  get   'chart_data' => 'home#chart_data'

  get   'reset_metrics' => 'home#reset_metrics'

end
