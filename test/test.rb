require "cwa"

cwa = CWA.get


cwa.alarms do |alm|
  pp alm[:alarm_name]
  pp cwa.disable(alm).methods
end
