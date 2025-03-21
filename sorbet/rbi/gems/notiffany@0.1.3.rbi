# typed: true

# DO NOT EDIT MANUALLY
# This is an autogenerated file for types exported from the `notiffany` gem.
# Please instead update this file by running `bin/tapioca gem notiffany`.


# TODO: this probably deserves a gem of it's own
#
# source://notiffany//lib/notiffany/notifier/base.rb#3
module Notiffany
  class << self
    # The notifier handles sending messages to different notifiers. Currently the
    # following libraries are supported:
    #
    # * Ruby GNTP
    # * Growl
    # * Libnotify
    # * rb-notifu
    # * emacs
    # * Terminal Notifier
    # * Terminal Title
    # * Tmux
    #
    # Please see the documentation of each notifier for more information about
    # the requirements
    # and configuration possibilities.
    #
    # Notiffany knows four different notification types:
    #
    # * success
    # * pending
    # * failed
    # * notify
    #
    # The notification type selection is based on the image option that is
    # sent to {#notify}. Each image type has its own notification type, and
    # notifications with custom images goes all sent as type `notify`. The
    # `gntp` notifier is able to register these types
    # at Growl and allows customization of each notification type.
    #
    # Notiffany can be configured to make use of more than one notifier at once.
    #
    # source://notiffany//lib/notiffany/notifier.rb#41
    def connect(options = T.unsafe(nil)); end
  end
end

# source://notiffany//lib/notiffany/notifier/base.rb#4
class Notiffany::Notifier
  # @return [Notifier] a new instance of Notifier
  #
  # source://notiffany//lib/notiffany/notifier.rb#82
  def initialize(opts); end

  # Test if notifiers are currently turned on
  #
  # @return [Boolean]
  #
  # source://notiffany//lib/notiffany/notifier.rb#138
  def active?; end

  # source://notiffany//lib/notiffany/notifier.rb#160
  def available; end

  # Returns the value of attribute config.
  #
  # source://notiffany//lib/notiffany/notifier.rb#80
  def config; end

  # source://notiffany//lib/notiffany/notifier.rb#92
  def disconnect; end

  # Test if the notifications can be enabled based on ENV['GUARD_NOTIFY']
  #
  # @return [Boolean]
  #
  # source://notiffany//lib/notiffany/notifier.rb#133
  def enabled?; end

  # Show a system notification with all configured notifiers.
  #
  # @option opts
  # @option opts
  # @param message [String] the message to show
  # @param opts [Hash] a customizable set of options
  #
  # source://notiffany//lib/notiffany/notifier.rb#148
  def notify(message, message_opts = T.unsafe(nil)); end

  # Turn notifications off.
  #
  # source://notiffany//lib/notiffany/notifier.rb#120
  def turn_off; end

  # Turn notifications on.
  #
  # @option options
  # @param options [Hash] the turn_on options
  #
  # source://notiffany//lib/notiffany/notifier.rb#109
  def turn_on(options = T.unsafe(nil)); end

  private

  # source://notiffany//lib/notiffany/notifier.rb#191
  def _activate; end

  # source://notiffany//lib/notiffany/notifier.rb#170
  def _check_server!; end

  # @return [Boolean]
  #
  # source://notiffany//lib/notiffany/notifier.rb#174
  def _client?; end

  # source://notiffany//lib/notiffany/notifier.rb#178
  def _detect_or_add_notifiers; end

  # source://notiffany//lib/notiffany/notifier.rb#166
  def _env; end

  # @return [Boolean]
  #
  # source://notiffany//lib/notiffany/notifier.rb#187
  def _notification_wanted?; end

  # source://notiffany//lib/notiffany/notifier.rb#202
  def _turn_on_notifiers(options); end
end

# source://notiffany//lib/notiffany/notifier/base.rb#5
class Notiffany::Notifier::Base
  # @return [Base] a new instance of Base
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#47
  def initialize(opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/base.rb#75
  def _image_path(image); end

  # source://notiffany//lib/notiffany/notifier/base.rb#66
  def name; end

  # source://notiffany//lib/notiffany/notifier/base.rb#70
  def notify(message, opts = T.unsafe(nil)); end

  # Returns the value of attribute options.
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#45
  def options; end

  # source://notiffany//lib/notiffany/notifier/base.rb#62
  def title; end

  private

  # Override
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#93
  def _check_available(_options); end

  # source://notiffany//lib/notiffany/notifier/base.rb#114
  def _check_host_supported; end

  # Override if necessary
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#83
  def _gem_name; end

  # source://notiffany//lib/notiffany/notifier/base.rb#102
  def _notification_type(image); end

  # source://notiffany//lib/notiffany/notifier/base.rb#106
  def _notify_options(overrides = T.unsafe(nil)); end

  # Override
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#98
  def _perform_notify(_message, _opts); end

  # source://notiffany//lib/notiffany/notifier/base.rb#120
  def _require_gem; end

  # Override if necessary
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#88
  def _supported_hosts; end
end

# source://notiffany//lib/notiffany/notifier/base.rb#19
Notiffany::Notifier::Base::ERROR_ADD_GEM_AND_RUN_BUNDLE = T.let(T.unsafe(nil), String)

# source://notiffany//lib/notiffany/notifier/base.rb#6
Notiffany::Notifier::Base::HOSTS = T.let(T.unsafe(nil), Hash)

# source://notiffany//lib/notiffany/notifier/base.rb#33
class Notiffany::Notifier::Base::RequireFailed < ::Notiffany::Notifier::Base::UnavailableError
  # @return [RequireFailed] a new instance of RequireFailed
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#34
  def initialize(gem_name); end
end

# source://notiffany//lib/notiffany/notifier/base.rb#22
class Notiffany::Notifier::Base::UnavailableError < ::RuntimeError
  # @return [UnavailableError] a new instance of UnavailableError
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#23
  def initialize(reason); end

  # source://notiffany//lib/notiffany/notifier/base.rb#28
  def message; end
end

# source://notiffany//lib/notiffany/notifier/base.rb#39
class Notiffany::Notifier::Base::UnsupportedPlatform < ::Notiffany::Notifier::Base::UnavailableError
  # @return [UnsupportedPlatform] a new instance of UnsupportedPlatform
  #
  # source://notiffany//lib/notiffany/notifier/base.rb#40
  def initialize; end
end

# Configuration class for Notifier
#
# source://notiffany//lib/notiffany/notifier/config.rb#6
class Notiffany::Notifier::Config
  # @return [Config] a new instance of Config
  #
  # source://notiffany//lib/notiffany/notifier/config.rb#13
  def initialize(opts); end

  # Returns the value of attribute env_namespace.
  #
  # source://notiffany//lib/notiffany/notifier/config.rb#9
  def env_namespace; end

  # Returns the value of attribute logger.
  #
  # source://notiffany//lib/notiffany/notifier/config.rb#10
  def logger; end

  # Returns the value of attribute notifiers.
  #
  # source://notiffany//lib/notiffany/notifier/config.rb#11
  def notifiers; end

  # @return [Boolean]
  #
  # source://notiffany//lib/notiffany/notifier/config.rb#21
  def notify?; end

  private

  # source://notiffany//lib/notiffany/notifier/config.rb#27
  def _setup_logger(opts); end
end

# source://notiffany//lib/notiffany/notifier/config.rb#7
Notiffany::Notifier::Config::DEFAULTS = T.let(T.unsafe(nil), Hash)

# @private api
#
# source://notiffany//lib/notiffany/notifier/detected.rb#27
class Notiffany::Notifier::Detected
  # @return [Detected] a new instance of Detected
  #
  # source://notiffany//lib/notiffany/notifier/detected.rb#47
  def initialize(supported, env_namespace, logger); end

  # Called when user has notifier-specific config.
  # Honor the config by warning if something is wrong
  #
  # source://notiffany//lib/notiffany/notifier/detected.rb#82
  def add(name, opts); end

  # source://notiffany//lib/notiffany/notifier/detected.rb#74
  def available; end

  # source://notiffany//lib/notiffany/notifier/detected.rb#57
  def detect; end

  # source://notiffany//lib/notiffany/notifier/detected.rb#53
  def reset; end

  private

  # source://notiffany//lib/notiffany/notifier/detected.rb#90
  def _add(name, opts); end

  # source://notiffany//lib/notiffany/notifier/detected.rb#117
  def _notifiers; end

  # source://notiffany//lib/notiffany/notifier/detected.rb#109
  def _to_module(name); end
end

# source://notiffany//lib/notiffany/notifier/detected.rb#28
Notiffany::Notifier::Detected::NO_SUPPORTED_NOTIFIERS = T.let(T.unsafe(nil), String)

# source://notiffany//lib/notiffany/notifier/detected.rb#31
class Notiffany::Notifier::Detected::NoneAvailableError < ::RuntimeError; end

# source://notiffany//lib/notiffany/notifier/detected.rb#34
class Notiffany::Notifier::Detected::UnknownNotifier < ::RuntimeError
  # @return [UnknownNotifier] a new instance of UnknownNotifier
  #
  # source://notiffany//lib/notiffany/notifier/detected.rb#35
  def initialize(name); end

  # source://notiffany//lib/notiffany/notifier/detected.rb#42
  def message; end

  # Returns the value of attribute name.
  #
  # source://notiffany//lib/notiffany/notifier/detected.rb#40
  def name; end
end

# Send a notification to Emacs with emacsclient
# (http://www.emacswiki.org/emacs/EmacsClient).
#
# source://notiffany//lib/notiffany/notifier/emacs/client.rb#4
class Notiffany::Notifier::Emacs < ::Notiffany::Notifier::Base
  private

  # @raise [UnavailableError]
  #
  # source://notiffany//lib/notiffany/notifier/emacs.rb#32
  def _check_available(options); end

  # Get the Emacs color for the notification type.
  # You can configure your own color by overwrite the defaults.
  #
  # notifications (default is 'ForestGreen')
  #
  # notifications (default is 'Firebrick')
  #
  # notifications
  #
  # 'Black')
  #
  # @option options
  # @option options
  # @option options
  # @option options
  # @param type [String] the notification type
  # @param options [Hash] aditional notification options
  # @return [String] the name of the emacs color
  #
  # source://notiffany//lib/notiffany/notifier/emacs.rb#86
  def _emacs_color(type, options = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/emacs.rb#91
  def _erb_for(filename); end

  # source://notiffany//lib/notiffany/notifier/emacs.rb#28
  def _gem_name; end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param type [String] the notification type. Either 'success',
  #   'pending', 'failed' or 'notify'
  # @param title [String] the notification title
  # @param message [String] the notification message body
  # @param image [String] the path to the notification image
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/emacs.rb#58
  def _perform_notify(message, opts = T.unsafe(nil)); end
end

# Handles evaluating ELISP code in Emacs via Erb
#
# source://notiffany//lib/notiffany/notifier/emacs/client.rb#6
class Notiffany::Notifier::Emacs::Client
  # @raise [ArgumentError]
  # @return [Client] a new instance of Client
  #
  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#28
  def initialize(options); end

  # @return [Boolean]
  #
  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#34
  def available?; end

  # Returns the value of attribute elisp_erb.
  #
  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#7
  def elisp_erb; end

  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#39
  def notify(color, bgcolor, message = T.unsafe(nil)); end

  private

  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#46
  def _emacs_eval(env, code); end
end

# Creates a safe binding with local variables for ERB
#
# source://notiffany//lib/notiffany/notifier/emacs/client.rb#10
class Notiffany::Notifier::Emacs::Client::Elisp < ::ERB
  # @return [Elisp] a new instance of Elisp
  #
  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#15
  def initialize(code, color, bgcolor, message); end

  # Returns the value of attribute bgcolor.
  #
  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#12
  def bgcolor; end

  # Returns the value of attribute color.
  #
  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#11
  def color; end

  # Returns the value of attribute message.
  #
  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#13
  def message; end

  # source://notiffany//lib/notiffany/notifier/emacs/client.rb#23
  def result; end
end

# source://notiffany//lib/notiffany/notifier/emacs.rb#12
Notiffany::Notifier::Emacs::DEFAULTS = T.let(T.unsafe(nil), Hash)

# source://notiffany//lib/notiffany/notifier/emacs.rb#20
Notiffany::Notifier::Emacs::DEFAULT_ELISP_ERB = T.let(T.unsafe(nil), String)

# source://notiffany//lib/notiffany/notifier.rb#0
class Notiffany::Notifier::Env < ::Nenv::Environment
  # source://nenv/0.3.0/lib/nenv/environment.rb#69
  def notify?; end

  # source://nenv/0.3.0/lib/nenv/environment.rb#59
  def notify_active=(raw_value); end

  # source://nenv/0.3.0/lib/nenv/environment.rb#69
  def notify_active?; end

  # source://nenv/0.3.0/lib/nenv/environment.rb#69
  def notify_pid; end

  # source://nenv/0.3.0/lib/nenv/environment.rb#59
  def notify_pid=(raw_value); end
end

# Writes notifications to a file.
#
# source://notiffany//lib/notiffany/notifier/file.rb#7
class Notiffany::Notifier::File < ::Notiffany::Notifier::Base
  private

  # @option opts
  # @param opts [Hash] some options
  #
  # source://notiffany//lib/notiffany/notifier/file.rb#16
  def _check_available(opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/file.rb#39
  def _gem_name; end

  # Writes the notification to a file. By default it writes type, title,
  # and message separated by newlines.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/file.rb#32
  def _perform_notify(message, opts = T.unsafe(nil)); end
end

# source://notiffany//lib/notiffany/notifier/file.rb#8
Notiffany::Notifier::File::DEFAULTS = T.let(T.unsafe(nil), Hash)

# System notifications using the
# [ruby_gntp](https://github.com/snaka/ruby_gntp) gem.
#
# This gem is available for OS X, Linux and Windows and sends system
# notifications to the following system notification frameworks through the
#
# [Growl Network Transport
# Protocol](http://www.growlforwindows.com/gfw/help/gntp.aspx):
#
# * [Growl](http://growl.info)
# * [Growl for Windows](http://www.growlforwindows.com)
# * [Growl for Linux](http://mattn.github.com/growl-for-linux)
# * [Snarl](https://sites.google.com/site/snarlapp)
#
# source://notiffany//lib/notiffany/notifier/gntp.rb#18
class Notiffany::Notifier::GNTP < ::Notiffany::Notifier::Base
  # source://notiffany//lib/notiffany/notifier/gntp.rb#39
  def _check_available(_opts); end

  # source://notiffany//lib/notiffany/notifier/gntp.rb#35
  def _gem_name; end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/gntp.rb#57
  def _perform_notify(message, opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/gntp.rb#30
  def _supported_hosts; end

  private

  # source://notiffany//lib/notiffany/notifier/gntp.rb#69
  def _gntp_client(opts = T.unsafe(nil)); end
end

# Default options for the ruby gtnp client.
#
# source://notiffany//lib/notiffany/notifier/gntp.rb#24
Notiffany::Notifier::GNTP::CLIENT_DEFAULTS = T.let(T.unsafe(nil), Hash)

# source://notiffany//lib/notiffany/notifier/gntp.rb#19
Notiffany::Notifier::GNTP::DEFAULTS = T.let(T.unsafe(nil), Hash)

# System notifications using the
# [growl](https://github.com/visionmedia/growl) gem.
#
# This gem is available for OS X and sends system notifications to
# [Growl](http://growl.info) through the
# [GrowlNotify](http://growl.info/downloads) executable.
#
# The `growlnotify` executable must be installed manually or by using
# [Homebrew](http://mxcl.github.com/homebrew/).
#
# Sending notifications with this notifier will not show the different
# notifications in the Growl preferences. Use the :gntp notifier if you
# want to customize each notification type in Growl.
#
# your `Guardfile` notification :growl, sticky: true, host: '192.168.1.5',
# password: 'secret'
#
# @example Install `growlnotify` with Homebrew
#   brew install growlnotify
# @example Add the `growl` gem to your `Gemfile`
#   group :development
#   gem 'growl'
#   end
# @example Add the `:growl` notifier to your `Guardfile`
#   notification :growl
# @example Add the `:growl_notify` notifier with configuration options to
#
# source://notiffany//lib/notiffany/notifier/growl.rb#34
class Notiffany::Notifier::Growl < ::Notiffany::Notifier::Base
  # source://notiffany//lib/notiffany/notifier/growl.rb#48
  def _check_available(_opts = T.unsafe(nil)); end

  # Shows a system notification.
  #
  # The documented options are for GrowlNotify 1.3, but the older options
  # are also supported. Please see `growlnotify --help`.
  #
  # Priority can be one of the following named keys: `Very Low`,
  # `Moderate`, `Normal`, `High`, `Emergency`. It can also be an integer
  # between -2 and 2.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/growl.rb#75
  def _perform_notify(message, opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/growl.rb#44
  def _supported_hosts; end
end

# Default options for the growl notifications.
#
# source://notiffany//lib/notiffany/notifier/growl.rb#39
Notiffany::Notifier::Growl::DEFAULTS = T.let(T.unsafe(nil), Hash)

# source://notiffany//lib/notiffany/notifier/growl.rb#35
Notiffany::Notifier::Growl::INSTALL_GROWLNOTIFY = T.let(T.unsafe(nil), String)

# System notifications using the
# [libnotify](https://github.com/splattael/libnotify) gem.
#
# This gem is available for Linux, FreeBSD, OpenBSD and Solaris and sends
# system notifications to
# Gnome [libnotify](http://developer.gnome.org/libnotify):
#
# source://notiffany//lib/notiffany/notifier/libnotify.rb#12
class Notiffany::Notifier::Libnotify < ::Notiffany::Notifier::Base
  private

  # source://notiffany//lib/notiffany/notifier/libnotify.rb#25
  def _check_available(_opts = T.unsafe(nil)); end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/libnotify.rb#42
  def _perform_notify(message, opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/libnotify.rb#21
  def _supported_hosts; end
end

# source://notiffany//lib/notiffany/notifier/libnotify.rb#13
Notiffany::Notifier::Libnotify::DEFAULTS = T.let(T.unsafe(nil), Hash)

# source://notiffany//lib/notiffany/notifier.rb#46
Notiffany::Notifier::NOTIFICATIONS_DISABLED = T.let(T.unsafe(nil), String)

# source://notiffany//lib/notiffany/notifier.rb#77
class Notiffany::Notifier::NotServer < ::RuntimeError; end

# System notifications using the
# [rb-notifu](https://github.com/stereobooster/rb-notifu) gem.
#
# This gem is available for Windows and sends system notifications to
# [Notifu](http://www.paralint.com/projects/notifu/index.html):
#
# @example Add the `rb-notifu` gem to your `Gemfile`
#   group :development
#   gem 'rb-notifu'
#   end
#
# source://notiffany//lib/notiffany/notifier/rb_notifu.rb#16
class Notiffany::Notifier::Notifu < ::Notiffany::Notifier::Base
  private

  # source://notiffany//lib/notiffany/notifier/rb_notifu.rb#37
  def _check_available(_opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/rb_notifu.rb#33
  def _gem_name; end

  # Converts generic notification type to the best matching
  # Notifu type.
  #
  # @param type [String] the generic notification type
  # @return [Symbol] the Notify notification type
  #
  # source://notiffany//lib/notiffany/notifier/rb_notifu.rb#77
  def _notifu_type(type); end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/rb_notifu.rb#61
  def _perform_notify(message, opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/rb_notifu.rb#29
  def _supported_hosts; end
end

# Default options for the rb-notifu notifications.
#
# source://notiffany//lib/notiffany/notifier/rb_notifu.rb#18
Notiffany::Notifier::Notifu::DEFAULTS = T.let(T.unsafe(nil), Hash)

# System notifications using notify-send, a binary that ships with
# the libnotify-bin package on many Debian-based distributions.
#
# @example Add the `:notifysend` notifier to your `Guardfile`
#   notification :notifysend
#
# source://notiffany//lib/notiffany/notifier/notifysend.rb#13
class Notiffany::Notifier::NotifySend < ::Notiffany::Notifier::Base
  private

  # source://notiffany//lib/notiffany/notifier/notifysend.rb#34
  def _check_available(_opts = T.unsafe(nil)); end

  # notify-send has no gem, just a binary to shell out
  #
  # source://notiffany//lib/notiffany/notifier/notifysend.rb#26
  def _gem_name; end

  # Converts Guards notification type to the best matching
  # notify-send urgency.
  #
  # @param type [String] the Guard notification type
  # @return [String] the notify-send urgency
  #
  # source://notiffany//lib/notiffany/notifier/notifysend.rb#71
  def _notifysend_urgency(type); end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/notifysend.rb#54
  def _perform_notify(message, opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/notifysend.rb#30
  def _supported_hosts; end

  # Builds a shell command out of a command string and option hash.
  #
  # shell command.
  #
  # @param command [String] the command execute
  # @param supported [Array] list of supported option flags
  # @param opts [Hash] additional command options
  # @return [Array<String>] the command and its options converted to a
  #
  # source://notiffany//lib/notiffany/notifier/notifysend.rb#84
  def _to_arguments(command, supported, opts = T.unsafe(nil)); end
end

# Default options for the notify-send notifications.
#
# source://notiffany//lib/notiffany/notifier/notifysend.rb#15
Notiffany::Notifier::NotifySend::DEFAULTS = T.let(T.unsafe(nil), Hash)

# Full list of options supported by notify-send.
#
# source://notiffany//lib/notiffany/notifier/notifysend.rb#21
Notiffany::Notifier::NotifySend::SUPPORTED = T.let(T.unsafe(nil), Array)

# source://notiffany//lib/notiffany/notifier.rb#51
Notiffany::Notifier::ONLY_NOTIFY = T.let(T.unsafe(nil), String)

# List of available notifiers, grouped by functionality
#
# source://notiffany//lib/notiffany/notifier.rb#54
Notiffany::Notifier::SUPPORTED = T.let(T.unsafe(nil), Array)

# System notifications using the
#
# [terminal-notifier](https://github.com/Springest/terminal-notifier-guard)
#
# gem.
#
# This gem is available for OS X 10.8 Mountain Lion and sends notifications
# to the OS X notification center.
#
# source://notiffany//lib/notiffany/notifier/terminal_notifier.rb#13
class Notiffany::Notifier::TerminalNotifier < ::Notiffany::Notifier::Base
  # source://notiffany//lib/notiffany/notifier/terminal_notifier.rb#27
  def _check_available(_opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/terminal_notifier.rb#23
  def _gem_name; end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @option opts
  # @param message [String] the notification message body
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/terminal_notifier.rb#45
  def _perform_notify(message, opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/terminal_notifier.rb#19
  def _supported_hosts; end
end

# source://notiffany//lib/notiffany/notifier/terminal_notifier.rb#14
Notiffany::Notifier::TerminalNotifier::DEFAULTS = T.let(T.unsafe(nil), Hash)

# source://notiffany//lib/notiffany/notifier/terminal_notifier.rb#16
Notiffany::Notifier::TerminalNotifier::ERROR_ONLY_OSX10 = T.let(T.unsafe(nil), String)

# Shows system notifications in the terminal title bar.
#
# source://notiffany//lib/notiffany/notifier/terminal_title.rb#7
class Notiffany::Notifier::TerminalTitle < ::Notiffany::Notifier::Base
  # Clears the terminal title
  #
  # source://notiffany//lib/notiffany/notifier/terminal_title.rb#11
  def turn_off; end

  private

  # source://notiffany//lib/notiffany/notifier/terminal_title.rb#21
  def _check_available(_options); end

  # source://notiffany//lib/notiffany/notifier/terminal_title.rb#17
  def _gem_name; end

  # Shows a system notification.
  #
  # @option opts
  # @option opts
  # @option opts
  # @param opts [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/terminal_title.rb#32
  def _perform_notify(message, opts = T.unsafe(nil)); end
end

# source://notiffany//lib/notiffany/notifier/terminal_title.rb#8
Notiffany::Notifier::TerminalTitle::DEFAULTS = T.let(T.unsafe(nil), Hash)

# Changes the color of the Tmux status bar and optionally
# shows messages in the status bar.
#
# source://notiffany//lib/notiffany/notifier/tmux/client.rb#5
class Notiffany::Notifier::Tmux < ::Notiffany::Notifier::Base
  # Notification stopping. Restore the previous Tmux state
  # if available (existing options are restored, new options
  # are unset) and unquiet the Tmux output.
  #
  # source://notiffany//lib/notiffany/notifier/tmux.rb#52
  def turn_off; end

  # Notification starting, save the current Tmux settings
  # and quiet the Tmux output.
  #
  # source://notiffany//lib/notiffany/notifier/tmux.rb#44
  def turn_on; end

  private

  # source://notiffany//lib/notiffany/notifier/tmux.rb#62
  def _check_available(opts = T.unsafe(nil)); end

  # source://notiffany//lib/notiffany/notifier/tmux.rb#58
  def _gem_name; end

  # Shows a system notification.
  #
  # By default, the Tmux notifier only makes
  # use of a color based notification, changing the background color of the
  # `color_location` to the color defined in either the `success`,
  # `failed`, `pending` or `default`, depending on the notification type.
  #
  # You may enable an extra explicit message by setting `display_message`
  # to true, and may further disable the colorization by setting
  # `change_color` to false.
  #
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @option options
  # @param message [String] the notification message
  # @param options [Hash] additional notification library options
  #
  # source://notiffany//lib/notiffany/notifier/tmux.rb#103
  def _perform_notify(message, options = T.unsafe(nil)); end

  class << self
    # source://notiffany//lib/notiffany/notifier/tmux.rb#120
    def _end_session; end

    # source://notiffany//lib/notiffany/notifier/tmux.rb#126
    def _session; end

    # source://notiffany//lib/notiffany/notifier/tmux.rb#115
    def _start_session; end
  end
end

# Class for actually calling TMux to run commands
#
# source://notiffany//lib/notiffany/notifier/tmux/client.rb#7
class Notiffany::Notifier::Tmux::Client
  # @return [Client] a new instance of Client
  #
  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#28
  def initialize(client); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#32
  def clients; end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#49
  def display_message(message); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#76
  def display_time=(time); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#72
  def message_bg=(color); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#68
  def message_fg=(color); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#63
  def parse_options; end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#42
  def set(key, value); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#80
  def title=(string); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#57
  def unset(key, value); end

  private

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#99
  def _all_args_for(key, value, client); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#91
  def _capture(*args); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#95
  def _parse_option(line); end

  # source://notiffany//lib/notiffany/notifier/tmux/client.rb#87
  def _run(*args); end

  class << self
    # source://notiffany//lib/notiffany/notifier/tmux/client.rb#19
    def _capture(*args); end

    # source://notiffany//lib/notiffany/notifier/tmux/client.rb#23
    def _run(*args); end

    # source://notiffany//lib/notiffany/notifier/tmux/client.rb#11
    def version; end
  end
end

# source://notiffany//lib/notiffany/notifier/tmux/client.rb#8
Notiffany::Notifier::Tmux::Client::CLIENT = T.let(T.unsafe(nil), String)

# source://notiffany//lib/notiffany/notifier/tmux.rb#15
Notiffany::Notifier::Tmux::DEFAULTS = T.let(T.unsafe(nil), Hash)

# source://notiffany//lib/notiffany/notifier/tmux.rb#39
Notiffany::Notifier::Tmux::ERROR_ANCIENT_TMUX = T.let(T.unsafe(nil), String)

# source://notiffany//lib/notiffany/notifier/tmux.rb#36
Notiffany::Notifier::Tmux::ERROR_NOT_INSIDE_TMUX = T.let(T.unsafe(nil), String)

# source://notiffany//lib/notiffany/notifier/tmux.rb#33
class Notiffany::Notifier::Tmux::Error < ::RuntimeError; end

# Wraps a notification with it's options
#
# source://notiffany//lib/notiffany/notifier/tmux/notification.rb#5
class Notiffany::Notifier::Tmux::Notification
  # @return [Notification] a new instance of Notification
  #
  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#6
  def initialize(type, options); end

  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#33
  def colorize(locations); end

  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#24
  def display_message(title, message); end

  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#15
  def display_title(title, message); end

  private

  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#54
  def _message_for(title, message); end

  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#48
  def _value_for(field); end

  # Returns the value of attribute client.
  #
  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#45
  def client; end

  # Returns the value of attribute color.
  #
  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#43
  def color; end

  # Returns the value of attribute message_color.
  #
  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#44
  def message_color; end

  # Returns the value of attribute options.
  #
  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#42
  def options; end

  # Returns the value of attribute separator.
  #
  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#46
  def separator; end

  # Returns the value of attribute type.
  #
  # source://notiffany//lib/notiffany/notifier/tmux/notification.rb#41
  def type; end
end

# Preserves TMux settings for all tmux sessions
#
# source://notiffany//lib/notiffany/notifier/tmux/session.rb#5
class Notiffany::Notifier::Tmux::Session
  # @return [Session] a new instance of Session
  #
  # source://notiffany//lib/notiffany/notifier/tmux/session.rb#6
  def initialize; end

  # source://notiffany//lib/notiffany/notifier/tmux/session.rb#29
  def close; end
end

# source://notiffany//lib/notiffany/notifier.rb#49
Notiffany::Notifier::USING_NOTIFIER = T.let(T.unsafe(nil), String)

# TODO: use a socket instead of passing env variables to child processes
# (currently probably only used by guard-cucumber anyway)
#
# source://notiffany//lib/notiffany/notifier/detected.rb#0
class Notiffany::Notifier::YamlEnvStorage < ::Nenv::Environment
  # source://nenv/0.3.0/lib/nenv/environment.rb#69
  def notifiers; end

  # source://nenv/0.3.0/lib/nenv/environment.rb#59
  def notifiers=(raw_value); end
end
