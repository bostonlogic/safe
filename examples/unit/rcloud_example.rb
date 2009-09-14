require File.expand_path(File.dirname(__FILE__) + '/../example_helper')

describe Astrails::Safe::Rcloud do

  def def_config
    {
      :rcloud => {
        :container => "_bucket",
        :username  => "_key",
        :api_key   => "_secret",
      },
      :keep => {
        :rcloud => 2
      }
    }
  end

  def def_backup
    {
      :kind      => "_kind",
      :filename  => "/backup/somewhere/_kind-_id.NOW.bar",
      :extension => ".bar",
      :id        => "_id",
      :timestamp => "NOW"
    }
  end

  def rcloud(config = def_config, backup = def_backup)
    Astrails::Safe::Rcloud.new(
      Astrails::Safe::Config::Node.new(nil, config),
      Astrails::Safe::Backup.new(backup)
    )
  end

#  describe :cleanup do

#    before(:each) do
#      @rcloud = rcloud

#      @files = [4,1,3,2].to_a.map { |i| stub(o = {}).key {"aaaaa#{i}"}; o }

#      stub(AWS::S3::Bucket).objects("_bucket", :prefix => "_kind/_id/_kind-_id.", :max_keys => 4) {@files}
#      stub(AWS::S3::Bucket).find("_bucket").stub![anything].stub!.delete
#    end

#    it "should check [:keep, :rcloud]" do
#      @rcloud.config[:keep][:rcloud] = nil
#      dont_allow(@rcloud.backup).filename
#      @rcloud.send :cleanup
#    end

#    it "should delete extra files" do
#      mock(AWS::S3::Bucket).find("_bucket").mock!["aaaaa1"].mock!.delete
#      mock(AWS::S3::Bucket).find("_bucket").mock!["aaaaa2"].mock!.delete
#      @rcloud.send :cleanup
#    end
#  end

  describe :active do
    before(:each) do
      @rcloud = rcloud
    end

    it "should be true when all params are set" do
      @rcloud.should be_active
    end

    it "should be false if container is missing" do
      @rcloud.config[:rcloud][:container] = nil
      @rcloud.should_not be_active
    end

    it "should be false if api_key is missing" do
      @rcloud.config[:rcloud][:api_key] = nil
      @rcloud.should_not be_active
    end

    it "should be false if username is missing" do
      @rcloud.config[:rcloud][:username] = nil
      @rcloud.should_not be_active
    end
  end

  describe :path do
    before(:each) do
      @rcloud = rcloud
    end
    it "should use rcloud/path 1st" do
      @rcloud.config[:rcloud][:path] = "rcloud_path"
      @rcloud.config[:local] = {:path => "local_path"}
      @rcloud.send(:path).should == "rcloud_path"
    end

    it "should use local/path 2nd" do
      @rcloud.config[:local] = {:path => "local_path"}
      @rcloud.send(:path).should == "local_path"
    end

    it "should use constant 3rd" do
      @rcloud.send(:path).should == "_kind/_id"
    end
  end

  describe :save do
    it "should establish rcloud connection"
    it "should RuntimeError if no local file (i.e. :local didn't run)"
    it "should upload file"
  end
  
end
