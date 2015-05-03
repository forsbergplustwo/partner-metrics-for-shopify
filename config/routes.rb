Rails.application.routes.draw do
  root to: 'home#index'

  post  '/'  => 'home#index'
  post  'import' => 'home#import'
  get   'recurring' => 'home#recurring'
  get   'onetime' => 'home#onetime'
  get   'affiliate' => 'home#affiliate'
  get   'chart_data' => 'home#chart_data'

  get   'reset_metrics' => 'home#reset_metrics'

end
