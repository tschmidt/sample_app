module Utilities
  module HTMLElements
    
    RSpec::Matchers.define :have_main_heading do |heading|
      match do |page|
        page.should have_selector('h1', text: heading)
      end
    end
    
    RSpec::Matchers.define :have_page_title do |title|
      match do |page|
        page.should have_selector('title', text: title)
      end
    end
    
    RSpec::Matchers.define :have_page_link do |*args|
      opts = args.extract_options!
      match do |page|
        page.should have_selector("a[href='#{opts[:href]}']", text: opts[:text])
      end
    end
    
  end
end