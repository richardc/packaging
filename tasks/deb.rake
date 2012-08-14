namespace :package do
  desc "Create .deb from this git repository."
  task :deb => :tar  do
    temp = get_temp
    cp_p "pkg/#{@name}-#{@version}.tar.gz", "#{temp}"
    cd temp do
      sh "tar zxf #{@name}-#{@version}.tar.gz"
      mv "#{@name}-#{@version}", "#{@name}-#{@debversion}"
      mv "#{@name}-#{@version}.tar.gz", "#{@name}_#{@origversion}.orig.tar.gz"
      cd "#{@name}-#{@debversion}" do
        mv File.join('ext', 'debian'), '.'
        build_cmd = "pdebuild --configfile #{@pbuild_conf} --buildresult #{temp} --pbuilder cowbuilder -- --basepath /var/cache/pbuilder/#{@cow}/"
        begin
          sh build_cmd
          dest_dir = File.join(@build_root, 'pkg', 'deb')
          mkdir_p dest_dir
          cp FileList["#{temp}/*.deb", "#{temp}/*.dsc", "#{temp}/*.changes", "#{temp}/*.debian.tar.gz", "#{temp}/*.orig.tar.gz"], dest_dir
          output = `find #{dest_dir}`
          puts
          puts "Wrote:"
          output.each_line do | line |
            puts "#{`pwd`.strip}/pkg/deb/#{line.split('/')[-1]}"
          end
        rescue
          STDERR.puts "Something went wrong. Hopefully the backscroll or #{temp}/#{@name}_#{@debversion}.build file has a clue."
        end
      end
      rm_rf temp
    end
  end
end

