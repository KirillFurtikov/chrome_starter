class ChromeRunner
  AUTHOR      = '@callhose'.freeze
  ERRORS_FILE = 'errors.log'
  CONFIG      = YAML.load_file(File.open('config.yml')).freeze
  PROJECTS    = CONFIG['project']
  PULSCEN     = PROJECTS['pulscen']['name'].freeze
  BLIZKO      = PROJECTS['blizko']['name'].freeze

  attr_reader :url, :project, :path, :browser, :role, :options

  def initialize(uri = nil)
    @url            = url(uri)
    @normalized_url = normalize_url(@url)
    @project        = project

    $logger.info "You have entered #{@project}"
    @path = role_auth_path(@project)

    $logger.info "Path is #{@path}"
    puts 'Запускаем браузер'

    begin
      $logger.info "Trying to start browser with options #{options.args}"
      @browser = Selenium::WebDriver.for :chrome,
                                         options: options
      puts "Авторизуюсь под ролью: #{@role}"

      $logger.info "Trying to navigate to normalized url #{@normalized_url} with path: #{@path}"
      @browser.navigate.to(@normalized_url + @path)

      $logger.info "Trying to navigate to url from arg: #{@url.to_s}"
      @browser.navigate.to(@url.to_s)
    rescue => e
      puts 'Что-то пошло не так :('
      puts "Опиши подробно, что привело к ошибке и скинь в телегу #{AUTHOR} файлы #{ERRORS_FILE} и logger.log"
      $logger.error 'Catching error...'
      trace(e)
    end
  end

  def options
    @options = Selenium::WebDriver::Chrome::Options.new
    @options.add_argument('--start-maximized')
    @options
  end

  def project
    url  = URI(@normalized_url)
    body = Net::HTTP.get(url).force_encoding('UTF-8')

    if body.include?(PROJECTS['pulscen']['mark'])
      $logger.info "Project was detected as #{PULSCEN} with key 1"
      puts "Проект автоматически определен - #{PULSCEN}"
      1
    elsif body.include?(PROJECTS['blizko']['mark'])
      $logger.info "Project was detected as #{BLIZKO} with key 2"
      puts "Проект автоматически определен - #{BLIZKO}"
      2
    else
      $logger.info 'Project wasn\'t detected'
      puts 'Не удалось автоматически определить проект'
      puts 'Выбери самостоятельно:'
      PROJECTS.each_with_index { |key, index| puts "#{index + 1}) #{PROJECTS[key[0]]['name']}" }
      gets.chomp.to_i
    end
  end

  def url(uri)
    print 'Введи урл: '
    $logger.info 'Ask url'
    url = uri.nil? ? gets.chomp : uri
    $logger.info "You have entered url: #{url}"
    url = URI(url)

    if url.scheme.nil? || url.host.nil?
      $logger.info 'You have entered incorrect url'
      puts 'Будь человеком, введи нормальный урл, а не ЭТО'
      raise 'Incorrect url!'
    else
      url
    end
  end

  def role_auth_path(project)
    $logger.info "role_auth_path(#{project})"
    roles =
      case project
      when 1
        PROJECTS['pulscen']['roles']
      when 2
        PROJECTS['blizko']['roles']
      else
        raise 'Incorrect project!'
      end

    $logger.info "roles: #{roles}"
    puts 'Роль:'
    roles.keys.each_with_index { |k, i| puts "#{i + 1}) #{k}" }
    role_index = gets.chomp.to_i - 1
    @role      = roles.keys[role_index]
    path       = roles[@role] # return path for authenticate

    if path.empty?
      $logger.info 'Current key has not value'
      puts 'Ключа для авторизация нет в файле config.yml'
      puts 'Выбери другую роль или заполни файл'
      return role_auth_path(@project)
    else
      $logger.info "Return: #{path}"
      path
    end
  end

  private

  def normalize_url(url)
    $logger.info 'Trying normalize url'
    url.host = url.host.to_s.split('.')[-4..-1].join('.')
    $logger.info "url.host: #{url.host}"
    url.scheme + '://' + url.host
  end

  def trace(error)
    $logger.info "Trying to save error backtrace to #{ERRORS_FILE}"
    File.open(File.join(Dir.pwd, ERRORS_FILE), 'w') do |f|
      f.puts error.inspect
      f.puts error.backtrace
    end

    $logger.info "Error backtrace was saved into #{ERRORS_FILE}"
  end
end
