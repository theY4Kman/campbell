# Taken from http://www.discoded.com/2012/04/05/my-favorite-javascript-string-extensions-in-coffeescript/
# Pythonized their names, though

if (typeof String::startswith != 'function')
  String::startswith = (str) ->
    return this.slice(0, str.length) == str

if (typeof String::endswith != 'function')
  String::endswith = (str) ->
    return this.slice(-str.length) == str
