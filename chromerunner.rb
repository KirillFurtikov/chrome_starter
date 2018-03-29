class ChromeRunner
  CONFIG = YAML.load_file(File.open('config.yml')).freeze

  attr_reader :url, :project, :path, :browser, :role

	def initialize(uri = nil)
    @url = url(uri)
		@project = project
    @path = role_auth_path(@project)
    puts 'Запускаем браузер'
		@browser = Selenium::WebDriver.for :chrome,
                                       options: options
    puts "Авторизуюсь под ролью: #{@role}"
		@browser.navigate.to @url + @path
  end

  def options
    options = Selenium::WebDriver::Chrome::Options.new
    options.add_argument('--start-maximized')
    options
  end

	def project
    puts 'Проект:'
		puts '1) Пульс Цен'
		puts '2) Близко'
		gets.chomp.to_i
	end
	
	def url(uri)
    print 'Введи урл: '
    url = uri.nil? ? gets.chomp : uri
    url = URI(url)
    if url.scheme.nil? || url.host.nil?
      puts 'Будь человеком, введи нормальный урл, а не ЭТО'
      raise 'Incorrect url!'
    else
      normalize_url(url)
    end
  end

  def role_auth_path(project)
    roles =
      case project
      when 1
        CONFIG['project']['pulscen']['roles']
      when 2
        CONFIG['project']['blizko']['roles']
      else
        raise 'Incorrect project!'
      end

    puts 'Роль:'
    roles.keys.each_with_index { |k, i| puts "#{i + 1}) #{k}" }
    role_index = gets.chomp.to_i
    @role = roles.keys[role_index]
    path = roles[@role] # return path for authenticate
    if path.empty?
      puts 'Ключа для авторизация нет в файле config.yml'
      puts 'Выбери другую роль или заполни файл'
      return role_auth_path(@project)
    else
      path
    end

  end

  private

  def normalize_url(url)
    url.host = url.host.to_s.split('.')[-4..-1].join('.')
    url.scheme + '://' + url.host
  end
end