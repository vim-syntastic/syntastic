" Vim syntax file
" Filename:     nagios.vim
" Language:     Nagios template object configuration file
" Author:       Ava Arachne Jarvis <ajar@katanalynx.dyndns.org>
" Author:       Lance Albertson <ramereth@gentoo.org>
" Author:       Vincent BESANCON <besancon.vincent@gmail.com>
" Author:       Canux CHENG <canuxcheng@gmail.com>
" Maintainer:   Elan Ruusamäe <glen@pld-linux.org>
" URL:          http://cvs.pld-linux.org/cgi-bin/cvsweb.cgi/packages/vim-syntax-nagios/nagios.vim
" Version Info: $Revision: 1.20 $
" Last Change:  $Date: 2009/10/16 10:11:29 $ UTC

if !exists("main_syntax")
  if version < 600
    syntax clear
  elseif exists("b:current_syntax")
    finish
  endif

  let main_syntax = 'nagios'
endif

if version >= 600
  setlocal iskeyword=_,-,A-Z,a-z,48-57
else
endif

syn match nagiosLineComment '^[\s]*#.*'
syn match nagiosLineComment '#.*'
syn match nagiosComment ';.*$' contained

syn match nagiosConstant '\<[0-9]\+%\?\>'
syn match nagiosConstant '\<[a-z]\>'

syn region nagiosString  start=+"+ end=+"+ contains=nagiosMacro
syn region nagiosString  start=+'+ end=+'+ contains=nagiosMacro

syn match nagiosDef 'define[ \t]\+\(\(host\|service\)extinfo\|host\|service\|timeperiod\|contact\|command\)'
syn match nagiosDef 'define[ \t]\+\(host\|contact\|service\)group'
syn match nagiosDef 'define[ \t]\+\(service\|host\)dependency'
syn match nagiosDef 'define[ \t]\+\(service\|host\|hostgroup\)escalation'

syn match nagiosMacro  '\$CONTACT\(NAME\|ALIAS\|EMAIL\|PAGER\)\$'
syn match nagiosMacro  '\$HOST\(NAME\|ALIAS\|ADDRESS\|STATE\|OUTPUT\|PERFDATA\|STATETYPE\|EXECUTIONTIME\)\$'
syn match nagiosMacro  '\$\(ARG\|USER\)\([1-9]\|[1-2][0-9]\|3[0-2]\)\$'
syn match nagiosMacro  '\$SERVICE\(DESC\|STATE\|OUTPUT\|PERFDATA\|LATENCY\|EXECUTIONTIME\|STATETYPE\)\$'
syn match nagiosMacro  '\$\(OUTPUT\|PERFDATA\|EXECUTIONTIME\|LATENCY\)\$'
syn match nagiosMacro  '\$NOTIFICATION\(TYPE\|NUMBER\)\$'
syn match nagiosMacro  '\$\(\(SHORT\|LONG\)\?DATETIME\|DATE\|TIME\|TIMET\)\$'
syn match nagiosMacro  '\$LASTSTATECHANGE\$'
syn match nagiosMacro  '\$ADMIN\(EMAIL\|PAGER\)\$'
syn match nagiosMacro  '\$\(SERVICE\|HOST\)ATTEMPT\$'
syn match nagiosMacro  '\$LAST\(HOST\|SERVICE\)CHECK\$'

syn match nagiosCustVar '\s\+_[A-Z0-9_]\+'
syn match nagiosCustVar '\$_\(HOST\|SERVICE\).*\$'

syn region nagiosDefBody start='{' end='}'
	\ contains=nagiosComment,nagiosLineComment,nagiosDirective,nagiosMacro,nagiosConstant,nagiosString,nagiosSpecial transparent

syn keyword nagiosDirective contained name register use
syn keyword nagiosDirective contained active_checks_enabled address alias check_command
syn keyword nagiosDirective contained check_freshness check_period checks_enabled check_interval retry_interval
syn keyword nagiosDirective contained command_line command_name
syn keyword nagiosDirective contained contacts contact_groups contact_name contactgroups contactgroup_name contactgroup_members
syn keyword nagiosDirective contained dependent_host_name dependent_hostgroup dependent_service_description dependent_servicegroup_name dependent_hostgroup_name
syn keyword nagiosDirective contained email event_handler event_handler_enabled
syn keyword nagiosDirective contained execution_failure_criteria first_notification first_notification_delay execution_failure_options
syn keyword nagiosDirective contained flap_detection_enabled flap_detection_options freshness_threshold failure_prediction_enabled
syn keyword nagiosDirective contained friday high_flap_threshold host_name display_name
syn keyword nagiosDirective contained host_notification_commands host_notifications_enabled
syn keyword nagiosDirective contained host_notification_options
syn keyword nagiosDirective contained host_notification_period hostgroup_name servicegroup_name servicegroup_members hostgroups hostgroup_members servicegroups
syn keyword nagiosDirective contained initial_state is_volatile last_notification
syn keyword nagiosDirective contained low_flap_threshold max_check_attempts
syn keyword nagiosDirective contained members monday normal_check_interval
syn keyword nagiosDirective contained notification_failure_criteria notification_failure_options
syn keyword nagiosDirective contained notification_interval notification_options
syn keyword nagiosDirective contained notification_period notifications_enabled
syn keyword nagiosDirective contained obsess_over_service pager parallelize_check
syn keyword nagiosDirective contained parents passive_checks_enabled
syn keyword nagiosDirective contained process_perf_data retain_nonstatus_information
syn keyword nagiosDirective contained retain_status_information retry_check_interval
syn keyword nagiosDirective contained saturday service_description can_submit_commands
syn keyword nagiosDirective contained service_notification_commands service_notifications_enabled
syn keyword nagiosDirective contained service_notification_options
syn keyword nagiosDirective contained service_notification_period stalking_options
syn keyword nagiosDirective contained sunday thursday timeperiod_name tuesday wednesday
syn keyword nagiosDirective contained icon_image icon_image_alt vrml_image statusmap_image
syn keyword nagiosDirective contained notes notes_url action_url 2d_coords 3d_coords obsess_over_host inherits_parent
syn keyword nagiosDirective contained escalation_period escalation_options

" custom objects: http://nagios.sourceforge.net/docs/3_0/customobjectvars.html
syn match nagiosDirective contained '\<_[a-z_]\+\>'
syn match nagiosMacro contained '\$_\(HOST\|SERVICE\|CONTACT\)[A-Z_]\+\$'

syn keyword nagiosSpecial null

hi link nagiosComment Comment
hi link nagiosLineComment Comment
hi link nagiosConstant Number
hi link nagiosDef Statement
hi link nagiosDirective Define
hi link nagiosMacro Macro
hi link nagiosString String
hi link nagiosSpecial Special
hi link nagiosCustVar Label
