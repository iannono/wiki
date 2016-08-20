2016 5-12
========

## Rails

before rails 5

```
# 如果user没有做出任何选择
<%= form_for(@user) do |f| %>
  <%= f.collection_radio_buttons :role_id, @roles, :id, :name %>
  <div class="actions">
    <%= f.submit %>
  </div>
<% end %>

def user_params
  params.require(:user).permit(:role_id)
end

# cause error
ActionController::ParameterMissing (param is missing or the value is empty: user):.
```

in rails 5
```
# auto add hidden user
Parameters: {"utf8"=>"✓", "authenticity_token"=>"...", "user"=>{"role_id"=>""}, "commit"=>"Create User"}
```

## Rails 5 adds ignored_columns for Active Record
```
class User < ApplicationRecord
  self.ignored_columns = %w(employee_email)
end
```

## Rails 5 adds ArrayInquirer and provides friendlier way to check contents in an array

```
pets = ActiveSupport::ArrayInquirer.new([:cat, :dog, 'rabbit'])

> pets.cat?
#=> true

> pets.rabbit?
#=> true

> pets.elephant?

> pets.any?(:cat, :dog)
#=> true

> pets.any?('cat', 'dog')
#=> true

> pets.any?(:rabbit, 'elephant')
#=> true

> pets.any?('elephant', :tiger)
#=> false
```

```
# 直接将数组转换
pets = [:cat, :dog, 'rabbit'].inquiry

> pets.cat?
#=> true

> pets.rabbit?
#=> true

> pets.elephant?
#=> false
```

```
# before rails 5
request.variant = :phone

> request.variant
#=> [:phone]

> request.variant.include?(:phone)
#=> true

> request.variant.include?('phone')
#=> false

# rails 5
request.variant = :phone

> request.variant.phone?
#=> true

> request.variant.tablet?
#=> false
```

## Rails 5 adds OR support in Active Record

```
>> Post.where(id: 1).or(Post.where(title: 'Learn Rails'))
   SELECT "posts".* FROM "posts" WHERE ("posts"."id" = ? OR "posts"."title" = ?)  [["id", 1], ["title", "Learn Rails"]]

=> <ActiveRecord::Relation [#<Post id: 1, title: 'Rails'>]>
```

```
class Post < ApplicationRecord

  scope :contains_blog_keyword, -> { where("title LIKE '%blog%'") }
  scope :id_greater_than, -> (id) {where("id > ?", id)}

  scope :containing_blog_keyword_with_id_greater_than, ->(id) { contains_blog_keyword.or(id_greater_than(id)) }
end

>> Post.containing_blog_keyword_with_id_greater_than(2)
SELECT "posts".* FROM "posts" WHERE ((title LIKE '%blog%') OR (id > 2)) ORDER BY "posts"."id" DESC
```

## Rails 5 introduces country_zones helper method to ActiveSupport::TimeZone

```
# before rails 5, only support us zones
> puts ActiveSupport::TimeZone.us_zones.map(&:to_s)
(GMT-10:00) Hawaii
(GMT-09:00) Alaska
(GMT-08:00) Pacific Time (US & Canada)
(GMT-07:00) Arizona
(GMT-07:00) Mountain Time (US & Canada)
(GMT-06:00) Central Time (US & Canada)
(GMT-05:00) Eastern Time (US & Canada)
(GMT-05:00) Indiana (East)

> puts ActiveSupport::TimeZone.country_zones('us').map(&:to_s)
(GMT-10:00) Hawaii
(GMT-09:00) Alaska
(GMT-08:00) Pacific Time (US & Canada)
(GMT-07:00) Arizona
(GMT-07:00) Mountain Time (US & Canada)
(GMT-06:00) Central Time (US & Canada)
(GMT-05:00) Eastern Time (US & Canada)
(GMT-05:00) Indiana (East)

>puts ActiveSupport::TimeZone.country_zones('fr').map(&:to_s)
 (GMT+01:00) Paris
```

## Rails 5 adds finish option in find_in_batches

```
Person.find_in_batches(start: 1000, batch_size: 2000) do |group|
  group.each { |person| person.party_all_night! }
end

# add finish method
Person.find_in_batches(start: 1000, finish: 9500, batch_size: 2000) do |group|
  group.each { |person| person.party_all_night! }
end
```

## Rails 5 prevents destructive action on production database

```
# rails 5 production 环境下是不允许执行以下命令的
$ rake db:schema:load

rake aborted!
ActiveRecord::ProtectedEnvironmentError: You are attempting to run a destructive action against your 'production' database.
If you are sure you want to continue, run the same command with the environment variable:
DISABLE_DATABASE_ENVIRONMENT_CHECK=1
```

## Rails 5 supports adding comments in migrations

```
class CreateProducts < ActiveRecord::Migration[5.0]
  def change
    create_table :products, comment: 'Products table' do |t|
      t.string :name, comment: 'Name of the product'
      t.string :barcode, comment: 'Barcode of the product'
      t.string :description, comment: 'Product details'
      t.float :msrp, comment: 'Maximum Retail Price'
      t.float :our_price, comment: 'Selling price'

      t.timestamps
    end

    add_index :products, :name,
              name: 'index_products_on_name',
              unique: true,
              comment: 'Index used to lookup product by name.'
  end
end

➜  rails_5_app rake db:migrate:up VERSION=20160429081156
== 20160429081156 CreateProducts: migrating ===================================
-- create_table(:products, {:comment=>"Products table"})
   -> 0.0119s
-- add_index(:products, :name, {:name=>"index_products_on_name", :unique=>true, :comment=>"Index used to lookup product by name."})
   -> 0.0038s
== 20160429081156 CreateProducts: migrated (0.0159s) ==========================


ActiveRecord::Schema.define(version: 20160429081156) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "products", force: :cascade, comment: "Products table" do |t|
      t.string   "name",                     comment: "Name of the product"
      t.string   "barcode",                  comment: "Barcode of the product"
      t.string   "description",              comment: "Product details"
      t.float    "msrp",                     comment: "Maximum Retail Price"
      t.float    "our_price",                comment: "Selling price"
      t.datetime "created_at",  null: false
      t.datetime "updated_at",  null: false
      t.index ["name"], name: "index_products_on_name", unique: true, using: :btree, comment: "Index used to lookup product by name."
    end
end
```

## Rails 5 adds helpers method in controllers to ease usage of helper modules in controllers

```
module UsersHelper
  def full_name(user)
    user.first_name + user.last_name
  end
end

class UsersController < ApplicationController
  include UsersHelper # we never use this in rails 5

  def update
    @user = User.find params[:id]
    if @user.update_attributes(user_params)
      redirect_to user_path(@user), notice: "#{full_name(@user) is successfully updated}"
      # rails 5 helpers.full_name(@user)
    else
      render :edit
    end
  end
end
```

## Rails 5 adds warning when fetching big result set with Active Record

```
>> Post.published.count
=> 25000

>> Post.where(published: true).each do |post|
     post.archive!
   end

# Loads 25000 posts in memory

config.active_record.warn_on_records_fetched_greater_than = 1500
```

## Rails 5 has added accessed_fields to find the fields that are actually being used in the application

我们可以通过使用accessed_fields确定视图中真正用到的字段， 从而重构我们的查询， 而只选出需要的字段
```
class UsersController < ApplicationController

  after_action :print_accessed_fields

  def index
    @users = User.all
  end

  private

  def print_accessed_fields
    p @users.first.accessed_fields
  end
end

User.select(:name, :email)
```

## Changes to test controllers in Rails 5

prefer url to action
```
rails 4
class ProductsControllerTest < ActionController::TestCase

  def test_index_response
    get :index
    assert_response :success
  end
end

rails 5
class ProductsControllerTest < ActionDispatch::IntegrationTest

  def test_index
    get products_url
    assert_response :success
  end
end
```

Depreate `assert_template` and `assigns`

> According to Rails team, controller tests should be more concerned about what is the result of that controller action like what cookies are set, or what HTTP code is set rather than testing of the internals of the controller

```
class ProductsControllerTest < ActionDispatch::IntegrationTest
  def test_index_template_rendered
    get products_url
    assert_template :index
    assert_equal Product.all, assigns(:products)
  end
end

# Throws exception
NoMethodError: assert_template has been extracted to a gem. To continue using it,
  add `gem 'rails-controller-testing'` to your Gemfile.
```

rails 5中的get 一类的方法支持命名参数, 使用更清楚了

```
rails 4
class ProductsControllerTest < ActionController::TestCase

  def test_show
    get :show, { id: user.id }, { notice: 'Welcome' }, { admin: user.admin? }
    assert_response :success
  end
end

rails 5
class ProductsControllerTest < ActionDispatch::IntegrationTest

  def test_create
    post product_url, params: { product: { name: "FIFA" } }
    assert_response :success
  end
end
```


2016-5-7
========

## replace rake to rails :rake

rails5中使用rails命令取代了原本的rake命令，通过rake proxy进行实现
而原有的部分包含railsnamespace的命令，都改为了以app作为namesapce

```
$ rails rails:update
$ rails rails:template
$ rails rails:templates:copy
$ rails rails:update:configs
$ rails rails:update:bin

$ rails app:update
$ rails app:template
$ rails app:templates:copy
$ rails app:update:configs
$ rails app:update:bin
```

## cache in development :cache

use this method turn on or turn off the cache in develoment
but this method is not support under unicorn, webrick and thin

因为该功能需要服务器能够监测restart.txt文件的创建， rails通过该功能来动态的创建该文件
从而实现服务器的自动重启

```
rails dev:cache
```


## cache result set and collection :cache

rails5 支持对set和collection的cache

```
@users = User.where(city: 'miami')
current_cache_key = @users.cache_key
=> "users/query-67ed32b36805c4b1ec1948b4eef8d58f-3-20160116111659084027"

该值由三部分组成： model， 查询语句和update的timestamp


# how to use
users = User.where(city: 'Miami')

if users.cache_key == current_cache_key
# do not hit db again and return the same cached page
else
# get data from database
end

# 通过该参数设置timestamp的依赖值
products.cache_key(:last_bought_at)
```

容易出错的地方：

```
# 使用limit的情况
 users = User.where(city: 'Miami').limit(3)
 users.cache_key
 => "users/query-67ed32b36805c4b1ec1948b4eef8d58f-3-20160116144936949365"

 User.where(city: 'Miami').limit(3).cache_key
 => "users/query-8dc512b1408302d7a51cf1177e478463-5-20160116144936949365"

# 不会触发更新条件的情况
 users1 = User.where(first_name: 'Sam').order('id desc').limit(3)
 users1.cache_key
 => "users/query-57ee9977bb0b04c84711702600aaa24b-3-20160116144936949365"

 User.find(3).destroy
 users2 = User.where(first_name: 'Sam').order('id desc').limit(3)
 users2.cache_key
 => "users/query-57ee9977bb0b04c84711702600aaa24b-3-20160116144936949365"

# 使用group的情况
 User.select(:first_name).group(:first_name).cache_key
 => "users/query-92270644d1ec90f5962523ed8dd7a795-1-20160118080134697603"

 users = User.select(:first_name).group(:first_name)
 users.cache_key
 => "users/query-92270644d1ec90f5962523ed8dd7a795-2-20160118080134697603"
```

## Rails 5 does not halt callback chain when false is returned :callback

rails 5 之前， 如果callback返回false， 则后续的callback都会停止
rails 5 中则不会停止， 想要停止的话， 得用`throw(:abort)`

```
before_save :set_eligibility_for_rebate

def set_eligibility_for_rebate
  self.eligibility_for_rebate ||= false
  throw(:abort)
end
```
如果不需要该功能， 可以关掉他

```
ActiveSupport.halt_callback_chains_on_return_false = false
```

## rails 5 makes belongs_to association required by default :association

如果belongs_to的对象不存在的时候， 该对象无法创建

```
class User < ApplicationRecord
end

class Post < ApplicationRecord
  belongs_to :user
end

post = Post.create(title: 'Hi')
=> <Post id: nil, title: "Hi", user_id: nil, created_at: nil, updated_at: nil>

post.errors.full_messages.to_sentence
=> "User must exist"
```

通过以下方式关闭该验证

```
Rails.application.config.active_record.belongs_to_required_by_default = false

class Post < ApplicationRecord
  belongs_to :user, optional: true
end
```


2016-4-30
=========

## response header :header

在rails5之前， 针对assets， 我们只能为response设置一种header：`config.static_cache_control = 'public, max-age=1000'`

这在我们使用nginx作为前端的静态文件处理的时候， 不会出现问题

但是， 如果我们使用heroku的话， heroku是需要rails自身来处理assets的

如果我们使用https://developers.google.com/speed/pagespeed/insights/来进行检查的话， google是建议我们添加expire的头标志的

而rails5则解决了这个问题：

```
config.public_file_server.headers = {
  'Cache-Control' => 'public, s-maxage=31536000, maxage=15552000',
  'Expires' => "#{1.year.from_now.to_formatted_s(:rfc822)}"
}
```

## application_record :model

rails5的model继承于`ApplicationRecord`了，并将该class暴露了出来， 这样可以避免一些针对`ActiveRecord::Base`的patch

```
class Post < ApplicationRecord
end
```

## test runner :test

现在我们可以直接用 `rails test`来运行测试了

1. 我们可以直接指定特定行数的测试来运行 `bin/rails test test/models/user_test.rb:27`
2. 同时指定多个测试 `bin/rails test test/models/user_test.rb:27 test/models/post_test.rb:42`
3. 错误信息中会直接输出错误的测试以及行数， 以便直接通过拷贝代码来运行测试
4. 加上-f参数，能在出错的时候， 就自动停止测试 `bin/rails t -f`
5. 加上-d参数， 能在test结束后， 输出所有的错误行
6. 加上-b参数， 能够输出更详细的堆栈错误
7. 通过-n参数， 能够通过正则表达式来进行匹配 `bin/rails t -n "/create/"`
8. 通过-v参数， 能显示每个测试执行的时间
9. 默认彩色输出

## render outside controller :render

```
OrdersController.render :show, assigns: { order: Order.last }
OrdersController.render :_form, locals: { order: Order.last }

OrdersController.render json: Order.all
# => "[{"id":1, "name":"The Well-Grounded Rubyist", "author":"David A. Black"},
       {"id":2, "name":"Remote: Office not required", "author":"David & Jason"}]

OrdersController.renderer.defaults
=> {:http_host=>"example.org", :https=>false, :method=>"get", :script_name=>"", :input=>""}
```

## CSRF token :csrf

CSRF的问题：

```
<script>
 var url = "http://mysite.com/grant_access?user_id=1&project_id=123";
 document.write('<form name=hack method=post action='+url+'></form>')
</script>
<img src='' onLoad="document.hack.submit()" />
```

rails 4 issue, 如果hacker在form外面再套上一层form, 并在action中进行hack，
那么当form被提交的时候， 提交的就是最外层的form， 同时还会附带`authenticity_token`

```
<form method="post" action="http://www.fraud.com/fraud">
  <form method= "post" action="/money_transfer">
    <input type="hidden" name="authenticity_token" value="token_value">
  </form>
</form>
```

solution:

```
<form method= "post" action="/money_transfer">
  <input type="hidden" name="authenticity_token" value="money_transfer_post_action_token">
</form>
```
