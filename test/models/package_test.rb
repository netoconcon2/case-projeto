require 'test_helper'

class PackageTest < ActiveSupport::TestCase
  test "should not persist in db" do
    assert_no_difference "Package.count", "a package without price should not be created" do
      Package.create(name: "Package test", words: 100)
    end
    assert_no_difference "Package.count", "a package without words should not be created" do
      Package.create(name: "Package test", price: 100)
    end
    assert_no_difference "Package.count", "a package without name should not be created" do
       Package.create(price: 100, words: 100)
    end
  end

  test "words cannot be equal or less than 0" do
    assert_no_difference "Package.count", "a package with negative words should not be created" do
       Package.create(name: "Package test", price: 100, words: 0)
    end
  end

  test "price cannot be equal or less than 1" do
    assert_no_difference "Package.count", "a package with negative price should not be created" do
       Package.create(name: "Package test", price: 1, words: 100)
    end
  end

  test "package saved without status should receive invisible as status" do
    package_test = Package.new(name: "Package test", price: 100, words: 100)
    assert_equal package_test.status, "invisible", "Package status didn't automatically save as invisible"
  end

  test "numbers should return respetive status" do
    package_invisible = Package.new(price: 100, words: 100, status: 0)
    package_visible = Package.new(price: 100, words: 100, status: 1)
    assert_equal package_invisible.status, "invisible", "status should be invisible"
    assert_equal package_visible.status, "visible", "status should be visible"
  end
end
