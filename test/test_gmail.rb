require 'test_helper'

class GmailTest < Test::Unit::TestCase
  def test_initialize
    imap = mock('imap')
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, true, nil, false).returns(imap)
    gmail = Gmail.new('test', 'password')
  end
  
  def test_imap_does_login
    setup_mocks(:at_exit => true)

    @gmail.imap
    breakdown_mocks
  end

  def test_imap_does_login_only_once
    setup_mocks(:at_exit => true, :login_attempts => 1)

    @gmail.imap
    @gmail.imap
    @gmail.imap
  end

  def test_imap_does_login_without_appending_gmail_domain
    setup_mocks(:at_exit => true, :user => 'test')

    @gmail.imap
  end
  
  def test_imap_logs_out
    setup_mocks(:at_exit => true)

    # @imap.expects(:disconnected?).at_least_once.returns(true).then.returns(false)
    # @imap.expects(:login).with('test@gmail.com', 'password')
    @gmail.imap
    @gmail.logout
    assert !@gmail.logged_in?
  end

  def test_imap_logout_does_nothing_if_not_logged_in
    setup_mocks

    @gmail.logout
  end
  
  def test_imap_calls_create_label
    setup_mocks(:at_exit => true)
    @imap.expects(:create).with('foo')
    @gmail.create_label('foo')
  end
  
  private
  def setup_mocks(options = {})
    options = {:at_exit => false, :login_attempts => 0, :user => 'test'}.merge(options)
    user_name = options[:user]
    @imap = mock('imap')
    @res = mock('imap_result')
    @res.expects(:name).at_least(0).returns("OK")
    @imap.expects(:login).at_least(options[:login_attempts]).with("#{user_name}@gmail.com", 'password').returns(@res)
    # need this for the at_exit block that auto-exits after this test method completes
    @imap.expects(:logout).at_least(0).returns(@res) if options[:at_exit]
    
    Net::IMAP.expects(:new).with('imap.gmail.com', 993, true, nil, false).returns(@imap)
    @gmail = Gmail.new(user_name, 'password')
  end
  
  def breakdown_mocks
    @gmail.logout
  end
end