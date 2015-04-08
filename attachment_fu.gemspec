# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name			  = %q{ss-attachment_fu}
  s.authors			  = ["Rick Olson", "Steven Pothoven"]
  s.summary			  = %q{attachment_fu as a gem}
  s.description		  = %q{This is a fork of Steven Pothoven's attachment_fu including custom some enhancements for Zoo Property}
  s.email			  = %q{m.yunan.helmy@gmail.com}
  s.homepage		  = %q{https://github.com/SoftwareSeniPT/attachment_fu}
  s.version			  = "3.2.17"
  s.date			  = %q{2015-04-08}

  s.files			  = Dir.glob("{lib,vendor}/**/*") + %w( CHANGELOG LICENSE README.rdoc amazon_s3.yml.tpl rackspace_cloudfiles.yml.tpl )
  s.extra_rdoc_files  = ["README.rdoc"]
  s.rdoc_options	  = ["--inline-source", "--charset=UTF-8"]
  s.require_paths	  = ["lib"]
  s.rubyforge_project = "nowarning"
  s.rubygems_version  = %q{1.8.29}

  if s.respond_to? :specification_version then
    s.specification_version = 2
  end
end