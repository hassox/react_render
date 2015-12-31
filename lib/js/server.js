var JSONStream = require('jsonstream')
var es = require('event-stream')

function handleRequest(data, callback) {
  callback(null, JSON.stringify(data) + '\n')
}

process.stdin
  .pipe(JSONStream.parse())
  .pipe(es.map(handleRequest))
  .pipe(process.stdout)
