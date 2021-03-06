require File.dirname(__FILE__) + '/../test_helper'

class PixivProxyTest < ActiveSupport::TestCase
  def test_get_profile
    results = PixivProxy.get_profile("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=9646484")
    assert_equal("シビレ\347\275\240", results[:artist])
    assert_equal("/member_illust.php?id=9646484", results[:listing_url])
  end
  
  def test_get_single
    results = PixivProxy.get_single("http://www.pixiv.net/member_illust.php?mode=medium&illust_id=9646484")
    assert_equal("/member.php?id=4015", results[:profile_url])
    assert(results[:jp_tags].size > 0)
    first_tag = results[:jp_tags][0]
    assert_equal(2, first_tag.size)
    assert(first_tag[0] =~ /./)
    assert(first_tag[1] =~ /tags\.php\?tag=/)
  end
end
