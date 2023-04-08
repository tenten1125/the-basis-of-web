 # webrick.rb
require 'webrick'
require 'erb'

server = WEBrick::HTTPServer.new({
  :DocumentRoot => './',
  :BindAddress => '127.0.0.1',
  :Port => 8000
})

server.mount_proc("/time") do |req, res|
  # レスポンス内容を出力
  body = "<html><body>\n"
  body += "#{Time.new}"
  body += "</body></html>\n"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

server.mount_proc("/form_get") do |req, res|
  # レスポンス内容を出力
  body = "<html><head><meta charset='utf-8'></head><body>\n"
  body += "クエリパラメータは#{req.query}です<br>\n"
  body += "こんにちは#{req.query['username']}さん。"
  body += "あなたの年齢は#{req.query['age']}ですね"
  body += "</body></html>\n"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

server.mount_proc("/form_post") do |req, res|
  # レスポンス内容を出力
  body = "<html><head><meta charset='utf-8'></head><body>\n"
  body += "フォームデータは#{req.query}です<br>\n"
  body += "こんにちは#{req.query['username']}さん。"
  body += "あなたの年齢は#{req.query['age']}ですね"
  body += "</body></html>\n"
  res.status = 200
  res['Content-Type'] = 'text/html'
  res.body = body
end

WEBrick::HTTPServlet::FileHandler.add_handler("erb", WEBrick::HTTPServlet::ERBHandler)
server.config[:MimeTypes]["erb"] = "text/html"

server.mount_proc("/hello") do |req, res|
  template = ERB.new( File.read('hello.erb') )
  # 現在時刻についてはインスタンス変数をここで定義してみるといいかも？
  @time = Time.new
  res.body << template.result( binding )
end

#総集編
foods = [
  { id: 1, name: "りんご", category: "fruits" },
  { id: 2, name: "バナナ", category: "fruits" },
  { id: 3, name: "いちご", category: "fruits" },
  { id: 4, name: "トマト", category: "vegetables" },
  { id: 5, name: "キャベツ", category: "vegetables" },
  { id: 6, name: "レタス", category: "vegetables" },
]

server.mount_proc("/foods") do |req, res|
  template = ERB.new( File.read('./foods/index.erb') )

  # ここにロジックを書く
  params = req.query["food"]
  @foods = []

  if params == "all"
    foods.each do |food|
      @foods.push(food)
    end
  elsif params == "fruits"
    foods.each do |food|
      if food[:category] == "fruits"
        @foods.push(food)
      end
    end
  else
    foods.each do |food|
      if food[:category] == "vegetables"
        @foods.push(food)
      end
    end
  end

  res.body << template.result( binding )
end

trap(:INT){
    server.shutdown
}

server.start
