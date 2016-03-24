request = require 'request'
path    = require 'path'
fs      = require 'fs'


downloadImage = (uri, filename, callback) ->
  mkdir path.dirname(filename)
  .then -> request.head uri, (err, res) ->
    console.log('content-type:', res.headers['content-type']);
    console.log('content-length:', res.headers['content-length']);
    request(uri).pipe(fs.createWriteStream(path.resolve(filename))).on('close', callback)

rmdir = (url) -> new Promise (resolve) ->
  if fs.existsSync(url)
    fs.readdirSync(url).forEach (file, index) ->
      curPath = url + "/" + file
      if fs.lstatSync(curPath).isDirectory() then rmdir curPath
      else
        fs.unlinkSync curPath
    fs.rmdirSync url
  resolve()


mkdir = (url) -> new Promise (resolve) ->
  url = path.resolve(url)
  fs.mkdir url, (error) ->
    if error and error.errno is -2
      mkdir path.dirname(url)
      .then ->
        mkdir url
        .then resolve
    else
      resolve()

dest = path.resolve process.argv[2]

rmdir(dest)
.then -> request 'https://image-a-day.herokuapp.com/image', (error, response, body) ->
  if not error and response.statusCode is 200
    {imageUrl} = JSON.parse(body)
    console.log imageUrl
    downloadImage imageUrl, dest + '/' + path.basename(imageUrl), ->
        console.log 'done'
