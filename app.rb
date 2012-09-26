require 'rubygems'
require 'json'
require 'sinatra'
require 'sinatra/reloader' if development?

helpers do
  def local_get(url)
    call(env.merge("PATH_INFO" => url)).last.join
  end
end

get '/' do
	haml :index, :layout => :template
end

get '/404' do
	status 404
	'404 Not Found'
end

get '/index' do
	"I'm the file at /index"
end

get '/:name/?' do |n|
	n.to_s
end

# TEMPORARY PROXY

def limitedUse (proxy)
	# if the proxy has limited uses:
	if (proxy['remainingUsages'])

		if proxy['remainingUsages'] == 0
			return nil
		end		

		proxy['remainingUsages'] -= 1
	end

	proxy
end

def maxIPs (proxy, remote_IP)
	if !proxy
		return nil
	end
	if (proxy['maxIPs'])
		current_ips = proxy['logged_IPs'] ? proxy['logged_IPs'] : []		
		if (current_ips.include? remote_IP) # is he on the list
			return proxy
		else # try to add him to the list
			if (current_ips.length < proxy['maxIPs'])  # if there's space
				current_ips.push(remote_IP)
				proxy['logged_IPs'] = current_ips
				return proxy
			else
				return nil
			end
		end
	end

	proxy
end

def processProxy (proxy, request)
	proxy = limitedUse(proxy)
	proxy = maxIPs(proxy, request.ip)
end

# The main proxy routing function
get '/temp/*' do

	# attempt to tell people not to cache
	status 302
	headers 'Cache-Control' => 'no-cache',
		'Pragma' => 'no-cache'


	@proxy_directory = '/views/temp' # bleh
	@proxy = File.join(Dir.pwd, @proxy_directory, params[:splat][0] + ".json")

	begin		
		# read the description of the proxy, which should be a JSON file in the @proxy_directory
		file = File.open(@proxy, "r")
		contents = file.read
		file.close
		# we expect it to be JSON
		p = JSON.parse(contents)

		# modify the temporary proxy:
		p = processProxy(p, request)

		# write the result

		if p
			# update a counter using write lock
			# don't use "w" because it truncates the file before lock.
			File.open(@proxy, File::RDWR|File::CREAT, 0644) {|f|
			  f.flock(File::LOCK_EX)
			  #sleep 5 # simulate a delay to test blocking
			  f.rewind
			  f.write(p.to_json)
			  f.flush
			  f.truncate(f.pos)
			}
		end

		# if it still exists, act on it
		if p
			local_get p['to']
		else
			local_get '/404'
		end
	rescue
		return local_get '/404'
	end
end