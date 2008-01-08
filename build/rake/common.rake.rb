#///////////////////////////////////////////////////
#
#	common.rake.rb
#	Copyright 2007 Tassilo Philipp
#	Rakefile
#
#///////////////////////////////////////////////////


# The target the user specified to make.
TARGET = ARGV[0].to_s
puts 'Making ' + (TARGET.empty? ? '"default"' : TARGET) + ' ...'


# Target ':autogen' to be used for files to be autogenerated.
# This will always be executed first.
task :default => :autogen
task :autogen


# Create a task for each "SUB".
if $SUBS then
	task :default   => $SUBS
	task :clean     => $SUBS
	task :distclean => $SUBS

	$SUBS.each do |s|
		task s do |t|
			Dir.chdir t.to_s do
				# Run rake recursively but don't search in
				# parent path to avoid endless recursion.
				exit unless system('rake --nosearch ' + TARGET) == true
			end
		end
	end
end


# Create tasks for each target to make.
if $OBJS then
	OBJNAMES = $OBJS.each_index { |i| $OBJS[i] = $OBJ_PREFIX + $OBJS[i] + $OBJ_SUFFIX }
	BINNAMES = OBJNAMES.clone


	# Static library.
	if $LIB then
		LIBNAME = $LIB_PREFIX + $LIB + $LIB_SUFFIX
		BINNAMES.push LIBNAME

		file LIBNAME => OBJNAMES

		task :default => [LIBNAME]
	end


	# Dynamic library.
	if $DLL then
		DLLNAME = $DLL_PREFIX + $DLL + $DLL_SUFFIX 
		BINNAMES.push DLLNAME

		file DLLNAME => OBJNAMES

		task :default => [DLLNAME]
	end


	# Executable.
	if $APP then
		APPNAME = $APP_PREFIX + $APP + $APP_SUFFIX
		BINNAMES.push APPNAME

		file APPNAME => OBJNAMES

		task :default => [APPNAME]
	end


	# Task to clean object files.
	task :clean do |t|
		puts 'Cleaning ...'
		BINNAMES.each { |f| File.delete(f) if File.exist?(f) == true }
	end

end


# Clean and remove autogenerated/temporary files.
task :clean
task :distclean => :clean do
	configFile = $TOP + 'config.rake.rb'
	File.delete($TOP + configFile) if File.exist?($TOP + configFile)
	$TEMPFILES.each { |f| File.delete(f) if File.exist?(f) == true } if $TEMPFILES 
end

