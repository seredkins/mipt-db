box.schema.create_space('users', {
    format = {
        { name = 'id', type = 'unsigned' },
        { name = 'bucket_id', type = 'unsigned' },
        { name = 'balance', type = 'double' },
        { name = 'spending_velocity', type = 'double' }
    },
    if_not_exists = true
})
box.space.users:create_index('id', { parts = { 'id' }, if_not_exists = true })
box.space.users:create_index('bucket_id', { parts = { 'bucket_id' }, unique = false, if_not_exists = true })

function insert_user(id, bucket_id, balance, spending_velocity)
    box.space.users:insert({ id, bucket_id, balance, spending_velocity })
end

function get_user(id)
    local tuple = box.space.users:get(id)
    if tuple == nil then
        return nil
    end
    return { tuple.id, tuple.balance, tuple.spending_velocity }
end

function add_money2user(id, money_delta)
    box.space.users:update(id, {{'+', 3, money_delta}})
    return true
end

function update_user_spending_velocity(id, spending_velocity)
    box.space.users:update(id, {{'=', 4, spending_velocity}})
    return true
end
