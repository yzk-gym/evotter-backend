require 'securerandom'
require 'sinatra'
require 'json'

get '/' do
  erb :index
end

# 動画生成API
# [params]下記のjson形式でパラメータを受け取る
# {
#   "before": {
#     "name": 進化前の名前,
#     "image": {
#       "data": 進化前の画像(base64文字列),
#       "type": "png" or "jpg" or "gif"
#     }
#   },
#   "after": {
#     "name": 進化後の名前,
#     "image": {
#       "data": 進化後の画像(base64文字列),
#       "type": "png" or "jpg" or "gif"
#     }
#   }
# }
post '/movie/create' do
  json_date = JSON.parse(request.body.read)
  puts json_date
  # before_object_image_file = params[:before][:image][:tempfile]
  # before_name = params[:before][:name]
  # after_object_image_file = params[:after][:image][:tempfile]
  # after_name = params[:after][:name]
  # movie_creator = MovieCreator.new(before_object_image_file, before_name, after_object_image_file, after_name)
  content_type :json
  { movie_path: "dummy_path" }.to_json
end

get '/movie/:id' do
  @movie_id = params['id']
  erb :movie
end

class MovieCreator

  BASE_BEFORE_IMAGE_PATH = "base-before.jpg"
  BASE_AFTER_IMAGE_PATH = "base-after.jpg"
  def initialize(before_object_image_file, before_name, after_object_image_file, after_name)
    @before_object_image_file = before_object_image_file
    @before_name = before_name
    @after_object_image_file = after_object_image_file
    @after_name = after_name
  end

  def create
    uuid = SecureRandom.uuid
    tmp_dir_path = "/tmp/#{uuid}"

    # 進化前オブジェクト画像の保存
    before_object_image_path = File.open("#{tmp_dir_path}/before_object_img#{File.extname(@before_object_image_file.path)}", 'wb') do |f|
      f.write(@before_object_image_file.read)
    end
    # 進化後オブジェクト画像の保存
    after_object_image_path = File.open("#{tmp_dir_path}/after_object_img#{File.extname(@after_object_image_file.path)}", 'wb') do |f|
      f.write(@after_object_image_file.read)
    end

    # 進化前メッセージ画像の生成
    before_msg_img_path = create_before_message_image(@before_name, tmp_dir_path)
    # 進化後メッセージ画像の生成
    after_msg_img_path = create_after_message_image(@before_name, @after_name, tmp_dir_path)

    # 合成:進化前メッセージ画像 + 進化前オブジェクト画像
    before_msg_before_obj_path = mix_before_msg_and_before_obj(before_msg_img_path, before_object_image_path, tmp_dir_path)
    # 合成:進化前メッセージ画像 + 進化後オブジェクト画像
    before_msg_after_obj_path = mix_before_msg_and_after_obj(before_msg_img_path, after_object_image_path, tmp_dir_path)
    # 合成:進化後メッセージ画像 + 進化後オブジェクト画像
    after_msg_after_obj_path = mix_after_msg_and_after_obj(after_msg_img_path, after_object_image_path, tmp_dir_path)

    # 画像ファイルの全コマ展開
    cut_image_path = create_tmp_images(before_msg_before_obj_path, before_msg_after_obj_path, after_msg_after_obj_path, tmp_dir_path)
    # 画像ファイルを動画へ変換
    no_sound_movie_path = create_movie(cut_image_path)
    # 動画と音声の合成
    movie_path = mix_movie_and_sound(no_sound_movie_path)

    # 作成した動画ファイルをS3へアップロード
    movie_url = update_s3(movie_path)
    # dynamoDBにID付与して動画URLを保存
    movie_id = save_movie(movie_url)
    # tmpファイルの全削除
    delete_tmp_files(tmp_dir_path)

    # 動画ファイルIDを返却
    movie_id
  end

  private

  def create_before_message_image(before_name, tmp_dir_path)
    output_path = "#{tmp_dir_path}/before_message_image.jpg"
    `convert -pointsize 24 -font pkmn_s.ttf -annotate 0x0+40+434 "#{before_name}の ようすが……！" #{BASE_BEFORE_IMAGE_PATH} #{output_path}`
    output_path
  end
  def create_after_message_image(before_name, after_name, tmp_dir_path)
    output_path = "#{tmp_dir_path}/after_message_image.jpg"
    `convert  -pointsize 24 -font pkmn_s.ttf -annotate 0x0+40+392 "おめでとう！　#{before_name}は" #{BASE_AFTER_IMAGE_PATH} #{output_path}`
    `convert  -pointsize 24 -font pkmn_s.ttf -annotate 0x0+40+434 "#{after_name}に　しんかした！" #{output_path} #{output_path}`
    output_path
  end
  def mix_before_msg_and_before_obj(before_message_image_path, before_object_image, tmp_dir_path)

  end
  def mix_before_msg_and_after_obj(before_message_image_path, after_object_image, tmp_dir_path)

  end
  def mix_after_msg_and_after_obj(after_message_image_path, after_object_image, tmp_dir_path)

  end
  def create_tmp_images(before_msg_before_obj_path, before_msg_after_obj_path, after_msg_after_obj_path, tmp_dir_path)

  end
  def create_movie(cut_image_path)

  end
  def mix_movie_and_sound(no_sound_movie_path)

  end
  def update_s3(movie_path)

  end
  def save_movie(movie_url)

  end
  def delete_tmp_files(tmp_dir_path)

  end
end
