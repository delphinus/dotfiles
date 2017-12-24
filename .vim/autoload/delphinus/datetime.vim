" http://stackoverflow.com/questions/12325291/parse-a-date-in-vimscript
function! delphinus#datetime#adjust_date(date, offset) abort
  let result = ''

  python3 <<EOP
import vim
import datetime

result = datetime.datetime.strptime(vim.eval('a:date'), '%Y-%m-%d') + \
    datetime.timedelta(days=int(vim.eval('a:offset')))
vim.command("let result = '" + result.strftime('%Y-%m-%d') + "'")
EOP

  return result
endfunction
