require "test_helper"

class DamageRelationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @damage_relation = damage_relations(:one)
  end

  test "should get index" do
    get damage_relations_url
    assert_response :success
  end

  test "should get new" do
    get new_damage_relation_url
    assert_response :success
  end

  test "should create damage_relation" do
    assert_difference("DamageRelation.count") do
      post damage_relations_url, params: { damage_relation: {} }
    end

    assert_redirected_to damage_relation_url(DamageRelation.last)
  end

  test "should show damage_relation" do
    get damage_relation_url(@damage_relation)
    assert_response :success
  end

  test "should get edit" do
    get edit_damage_relation_url(@damage_relation)
    assert_response :success
  end

  test "should update damage_relation" do
    patch damage_relation_url(@damage_relation), params: { damage_relation: {} }
    assert_redirected_to damage_relation_url(@damage_relation)
  end

  test "should destroy damage_relation" do
    assert_difference("DamageRelation.count", -1) do
      delete damage_relation_url(@damage_relation)
    end

    assert_redirected_to damage_relations_url
  end
end
