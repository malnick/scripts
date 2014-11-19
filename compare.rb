require 'logger'
class Compare
	def initialize(repodir, pfile)
		@log = Logger.new(STDOUT) 
		mrepo = repodir
		pfile = pfile
		
		mrepo_ary = get_mrepo_contents(mrepo)
		pfile_ary = create_pfile_ary(pfile)
		compare(mrepo_ary, pfile_ary)
	end

	def get_mrepo_contents(mrepo)
		entries = Dir.entries(mrepo)
		#@log.info(entries)
		entries
	end

	def create_pfile_ary(pfile)
		pfile_ary = []
		file = File.open(pfile)
		file.each do |line|
			if ! line.empty?
				pfile_ary.push(line)
			end
		end
		#@log.info(pfile_ary)
		pfile_ary
	end

	def compare(mrepo_ary, pfile_ary)
		matches = []
		unmatched = []
		
		mrepo_ary.each do |re|
			catch :iterate do
				pfile_ary.each do |fe|
					if fe.include?(re)
						@log.info("MATCH FOUND: Directory entry: #{re} && Puppetfile entry: #{fe}")
						matches.push(re)
						throw :iterate
					end		
				end
				@log.info("Match not found for directory entry: #{re}")
				unmatched.push(re)
			end
		end
		matches.each do |match|
			@log.info("Puppetfile contains: #{match}")
		end
		@log.info("#" * 20)
		unmatched.each do |um|
			@log.info("Puppetfile missing: #{um}")
		end
	end

end

Compare.new(ARGV[0], ARGV[1])
