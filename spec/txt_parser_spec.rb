require 'spec_helper'
require 'fixtures_helper'

describe Irobot::TxtParser do
  let(:goodbot) { 'goodbot' }
  let(:badbot) { 'badbot' }
  let(:paths) { ['', '/', '/foo', '/index.html'] }
  let(:bots) { [goodbot, badbot] }
  let(:parser) do
    proc { |filename, path, ua| Irobot::TxtParser.new(robot_txt(filename), path, ua) }
  end

  context 'allow_all_to_all' do
    let(:txt_parser) { parser.curry['allow_all_to_all'] }

    it 'will allow all robots to any path' do
      paths.product(bots).each do |path, bot|
        expect(txt_parser.(path, bot).allowed?).to be_true
      end
    end
  end

  context 'allow_all_to_all_incomplete' do
    let(:txt_parser) { parser.curry['allow_all_to_all_incomplete'] }

    it 'will allow all robots to any path when no path is given for Allow directive' do
      paths.product(bots).each do |path, bot|
        expect(txt_parser.(path, bot).allowed?).to be_true
      end
    end
  end

  context 'disallow_all_from_all' do
    let(:txt_parser) { parser.curry['disallow_all_from_all'] }

    it 'will exclude all robots from all paths' do
      paths.product(bots).each do |path, bot|
        expect(txt_parser.(path, bot).allowed?).to be_false
      end
    end
  end

  context 'disallow_all_from_all_incomplete' do
    let(:txt_parser) { parser.curry['disallow_all_from_all_incomplete'] }

    it 'will allow all robots to any path when no path is given for Disallow directive' do
      paths.product(bots).each do |path, bot|
        expect(txt_parser.(path, bot).allowed?).to be_true
      end
    end
  end

  context 'disallow_all_from_specific_dir' do
    let(:txt_parser) { parser.curry['disallow_all_from_specific_dir'] }

    it 'will exclude all robots to specific directories with trailing slash' do
      bots.each do |bot|
        expect(txt_parser.('/private/', bot).allowed?).to be_false
      end
    end

    it 'will exclude all robots from files inside a disallow directories' do
      bots.each do |bot|
        expect(txt_parser.('/private/index.html', bot).allowed?).to be_false
      end
    end

    it 'will exclude all robots to specific directories without trailing slash' do
      bots.each do |bot|
        expect(txt_parser.('/private', bot).allowed?).to be_false
      end
    end

    it 'will not exclude any robots to a directory that matches a disallow directory' do
      pending 'There is a bug in TxtParser.to_regex'
      # bots.each do |bot|
      #   expect(txt_parser.('/private-just-kidding', bot).allowed?).to be_true
      # end
    end
  end

  context 'disallow_all_from_specific_file' do
    let(:txt_parser) { parser.curry['disallow_all_from_specific_file'] }

    it 'will disallow all robots to a disallowed file' do
      bots.each do |bot|
        expect(txt_parser.('/private/index.html', bot).allowed?).to be_false
      end
    end

    it 'will allow all robots to a directory with the name of a disallowed file' do
      bots.each do |bot|
        expect(txt_parser.('/private/index', bot).allowed?).to be_true
      end
    end

    it 'will allow all robots to a directories which has a disallowed file' do
      bots.each do |bot|
        expect(txt_parser.('/private/', bot).allowed?).to be_true
      end
    end
  end

  context 'disallow_specific_bot' do
    let(:txt_parser) { parser.curry['disallow_specific_bot'] }

    it 'will disallow only specific robots from a website' do
      expect(txt_parser.('/private/index.html', goodbot).allowed?).to be_true
      expect(txt_parser.('/private/index.html', badbot).allowed?).to be_false
    end
  end

  context 'disallow_mishmash' do
    let(:txt_parser) { parser.curry['disallow_mishmash'] }

    it 'will determine access to directories based on which robot is asking' do
      expect(txt_parser.('/bad', badbot).allowed?).to be_true
      expect(txt_parser.('/bad/', goodbot).allowed?).to be_false

      expect(txt_parser.('/good/', badbot).allowed?).to be_false
      expect(txt_parser.('/good/', goodbot).allowed?).to be_true
    end
  end

  context 'disallow_specific_bot' do
    let(:txt_parser) { parser.curry['disallow_specific_bot'] }

    it 'will disallow only specific robots from a website' do
      expect(txt_parser.('/', goodbot).allowed?).to be_true
      expect(txt_parser.('/', badbot).allowed?).to be_false
    end

    it 'will disallow only specific robots from a directory' do
      expect(txt_parser.('/private', goodbot).allowed?).to be_true
      expect(txt_parser.('/private', badbot).allowed?).to be_false
    end

    it 'will disallow only specific robots from a directory' do
      expect(txt_parser.('/private/index.html', goodbot).allowed?).to be_true
      expect(txt_parser.('/private/index.html', badbot).allowed?).to be_false
    end
  end

  context 'allow_to_file_in_disallowed_dir' do
    let(:txt_parser) { parser.curry['allow_to_file_in_disallowed_dir'] }

    it 'will disallow to private directory' do
      expect(txt_parser.('/private', goodbot).allowed?).to be_false
    end

    it 'will allow to crawlable subdirectory in disallowed directory' do
      expect(txt_parser.('/private/crawlable', goodbot).allowed?).to be_true
    end

    it 'will allow to file in disallowed directory' do
      expect(txt_parser.('/private/allow.html', badbot).allowed?).to be_true
    end
  end

  context 'disallow_with_query' do
    let(:txt_parser) { parser.curry['disallow_with_query'] }

    it 'will not allow to path with query string' do
      expect(txt_parser.('/request_params?a=a', goodbot).allowed?).to be_false
      expect(txt_parser.('/matrix_params;a=a', goodbot).allowed?).to be_false
    end

    it 'will disallow when robots.txt uses a wildcard' do
      # In allowed, we match against the path and the path is the uri.request_path
      # and does not include params.
      pending 'The current parser does not support this'
      # expect(txt_parser.('/private/foo?a=a&t=t&z=z', goodbot).allowed?).to be_false
    end
  end

  # Tests are skipped unless config is modified
  context 'Crawl-delay' do
    let(:txt_parser) { parser.curry['crawl_delay'] }

    it 'will respect crawl delay and sleep for 2 seconds' do
      if Irobot.config.respect_crawl_delay
        start = Time.now
        txt_parser.('/', badbot).allowed?
        expect(Time.now - start).to be >= expected_duration
      else
        pending 'Skipping test: config.respect_crawl_delay is false'
      end
    end

    it 'will respect crawl delay and sleep for 1 second' do
      if Irobot.config.respect_crawl_delay
        start = Time.now
        txt_parser.('/', goodbot).allowed?
        expect(Time.now - start).to be >= 1
      else
        pending 'Skipping test: config.respect_crawl_delay is false'
      end
    end
  end
end
