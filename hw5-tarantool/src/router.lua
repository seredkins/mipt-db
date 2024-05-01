local vshard = require('vshard')

function put(id, balance, spending_velocity)
    local bucket_id = vshard.router.bucket_id_mpcrc32({ id })
    vshard.router.callrw(bucket_id, 'insert_user', { id, bucket_id, balance, spending_velocity })
end

function get(id)
    local bucket_id = vshard.router.bucket_id_mpcrc32({ id })
    return vshard.router.callro(bucket_id, 'get_user', { id })
end

function insert_data()
    put(1, 87, 0.001)
    put(2, 123, 0.01)
    put(3, 1.5, 1)
    put(4, 0, 0)
    put(5, 1000, 0.1)
    put(6, 5, 0.5)
    put(7, 23948792, 0.1)
    put(8, 1, 0.00001)
    put(9, 900, 23)
    put(10, 912308, 837)
end

function add_money(id, money_delta)
    local bucket_id = vshard.router.bucket_id_mpcrc32({ id })
    return vshard.router.callrw(bucket_id, 'add_money2user', { id, money_delta })
end

function update_spending_velocity(id, new_spending_velocity)
    local bucket_id = vshard.router.bucket_id_mpcrc32({ id })
    return vshard.router.callrw(bucket_id, 'update_user_spending_velocity', { id, new_spending_velocity })
end
