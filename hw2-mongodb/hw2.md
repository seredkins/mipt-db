1. **Создание базы данных и коллекции**
```
test> use mipt_db_hw2
switched to db mipt_db_hw2

mipt_db_hw2> db.createCollection("customers")
{ ok: 1 }
mipt_db_hw2>

mipt_db_hw2> show dbs
admin         40.00 KiB
config       108.00 KiB
local         40.00 KiB
mipt_db_hw2    8.00 KiB
```

<br>
<br>

2. **Загрузка данных в коллекцию**

Данные посетителей магазина: id, пол, возраст, доход, рейтинг трат. Ссылка на данные: [Mall_Customers.csv](https://www.kaggle.com/shwetabh123/mall-customers)

```
hw2-mongodb ) mongoimport \
                  --collection='customers' \
                  --file=Mall_Customers.csv \
                  --type=csv \
                  --headerline \
                  --db=mipt_db_hw2
2024-03-30T18:40:09.980+0300	connected to: mongodb://localhost/
2024-03-30T18:40:09.994+0300	200 document(s) imported successfully. 0 document(s) failed to import.
```

<br>
<br>

3. **Запросы на выборку**
```javascript
mipt_db_hw2> db.customers.findOne()
{
  _id: ObjectId('6608325950f2c8fcabdfacea'),
  CustomerID: 2,
  Genre: 'Male',
  Age: 21,
  'Annual Income (k$)': 15,
  'Spending Score (1-100)': 81
}
```
```javascript
mipt_db_hw2> db.customers.find({Age : {$lte : 18}, Genre : 'Male'}, {_id : 0})
[
  {
    CustomerID: 34,
    Genre: 'Male',
    Age: 18,
    'Annual Income (k$)': 33,
    'Spending Score (1-100)': 92
  },
  {
    CustomerID: 66,
    Genre: 'Male',
    Age: 18,
    'Annual Income (k$)': 48,
    'Spending Score (1-100)': 59
  },
  {
    CustomerID: 92,
    Genre: 'Male',
    Age: 18,
    'Annual Income (k$)': 59,
    'Spending Score (1-100)': 41
  }
]
mipt_db_hw2> db.customers.find({Age : {$lte : 18}, Genre : 'Male'}, {_id : 0}).explain("executionStats")["executionStats"]["executionTimeMillis"]
5
```

Среднее время запроса на выборку по возрасту без индексации = 0.01 мс.:
```javascript
mipt_db_hw2> var  mean_exec_time = 0

mipt_db_hw2> for (var i = 0; i < 10000; ++i) { 
    mean_exec_time = mean_exec_time + db.customers.find(
        { Age: { $gte: 30 }}
    ).explain("executionStats")["executionStats"]["executionTimeMillis"]; 
}
99
mipt_db_hw2> mean_exec_time / 10000
0.0099
```

<br>
<br>

4. **Запросы на вставку, обновление и удаление данных**
```javascript
mipt_db_hw2> db.customers.insertOne({CustomerID : 201, Genre : 'Male' , Age : 20, 'Annual Income (k$)' : 500, 'Spending Score (1-100)' : 67})
{
  acknowledged: true,
  insertedId: ObjectId('660838304d3a8f274a2a16ef')
}
```
```javascript
mipt_db_hw2> db.customers.updateOne({CustomerID : 201}, {$set : {Age : 21}})
{
  acknowledged: true,
  insertedId: null,
  matchedCount: 1,
  modifiedCount: 1,
  upsertedCount: 0
}
```
```javascript
mipt_db_hw2> db.customers.deleteOne({CustomerID : 201})
{
  acknowledged: true,
  deletedCount: 1
}
```

<br>
<br>

5. **Запрос на множественную вставку**
```javascript
mipt_db_hw2> db.customers.insertMany([{CustomerID : 202, Age : 22, 'Annual Income (k$)' : 130, 'Spending Score (1-100)' : 56}, {CustomerID : 203, Age : 23, 'Annual Income (k$)' : 150, 'Spending Score (1-100)' : 23}])
{
  acknowledged: true,
  insertedIds: {
    '0': ObjectId('66083cca4d3a8f274a2a16f0'),
    '1': ObjectId('66083cca4d3a8f274a2a16f1')
  }
}
```

<br>
<br>

6. **Запросы на аггрегированную выборку**
```javascript
mipt_db_hw2> db.customers.aggregate([{$match : {Age : {$gte : 19}}}, {$group : {_id : "$Genre", mean_income : {$avg : '$Annual Income (k$)'}}}])
[
  { _id: 'Male', mean_income: 62.77647058823529 },
  { _id: 'Female', mean_income: 59.1981981981982 }
]
```
Среднее время выполнения запроса на аггрегированную выборку без индексации по возрасту = 0.448 мс.:
```javascript
mipt_db_hw2> var  mean_exec_time = 0

mipt_db_hw2> for (var i = 0; i < 10000; ++i) { 
    mean_exec_time = mean_exec_time + db.customers.aggregate([
        { $match: { Age: { $gte: 19 } } }, 
        { $group: { _id: "$Genre", mean_income: { $avg: '$Annual Income (k$)' } } 
    }]).explain("executionStats")["executionStats"]["executionTimeMillis"]; 
}
4480
mipt_db_hw2> mean_exec_time / 10000
0.448
```

<br>
<br>

7. **Добавление и удаление индекса, производительность запросов к индексированной коллекции**
```
mipt_db_hw2> db.customers.createIndex({Age : 1})
Age_1
```

Среднее время выполнения запроса на аггрегированную выборку с индексацией по возрасту = 0.9027 мс. -- рост в 2 раза по сравнению с отсутствием индексации:
```javascript
mipt_db_hw2> var  mean_exec_time = 0

mipt_db_hw2> for (var i = 0; i < 10000; ++i) { 
    mean_exec_time = mean_exec_time + db.customers.aggregate([
        { $match: { Age: { $gte: 19 } } }, 
        { $group: { _id: "$Genre", mean_income: { $avg: '$Annual Income (k$)' } } 
    }]).explain("executionStats")["executionStats"]["executionTimeMillis"]; 
}
9027
mipt_db_hw2> mean_exec_time / 10000
0.9027
```

Среднее время выполнения запроса на выборку по возрасту c индексацией = 0.02 мс. -- рост в 2 раза по сравнению с отсутствием индексации:
```javascript
mipt_db_hw2> var  mean_exec_time = 0

mipt_db_hw2> for (var i = 0; i < 10000; ++i) { 
    mean_exec_time = mean_exec_time + db.customers.find(
        { Age: { $gte: 30 }}
    ).explain("executionStats")["executionStats"]["executionTimeMillis"]; 
}
200
mipt_db_hw2> mean_exec_time / 10000
0.02
```

```
mipt_db_hw2> db.customers.dropIndex("Age_1")
{ nIndexesWas: 2, ok: 1 }
```

<br>
<br>

8. **Сравнение производительности запросов на выборку по возрасту с индексацией и без в большой базе данных** `uber` на 14.3 млн. записей. Ссылка на данные: [uber-raw-data-janjune-15.csv](https://www.kaggle.com/datasets/fivethirtyeight/uber-pickups-in-new-york-city)

Без индексации:
```javascript
mipt_db_hw2> var  mean_exec_time = 0

mipt_db_hw2> for (var i = 0; i < 5; ++i) { 
    mean_exec_time = mean_exec_time + db.uber.find(
        { Date: { $gte: "2015-01-01" }}
    ).explain("executionStats")["executionStats"]["executionTimeMillis"]; 
}
41996
mipt_db_hw2> mean_exec_time / 5
8399.2
```
С индексацией:
```
mipt_db_hw2> db.uber.createIndex({Date : 1})
Date_1
```
```javascript
mipt_db_hw2> var  mean_exec_time = 0

mipt_db_hw2> for (var i = 0; i < 5; ++i) { 
    mean_exec_time = mean_exec_time + db.uber.find(
        { Date: { $gte: "2015-01-01" }}
    ).explain("executionStats")["executionStats"]["executionTimeMillis"]; 
}
11
mipt_db_hw2> mean_exec_time / 5
2.2
```

**Вывод:** Индексация значительно (на несколько порядков) ускоряет выполнение запросов на выборку по индексированному полю при большом объеме данных. При маленьком объеме данных (порядка сотен записей) индексация только увеличивает время выполнения запросов (раза в 2). Возможно это связано с тем, что есть накладные расходы при обращении к дополнительной информации в индексах, которые при малом объеме данных превышают выигрыш от индексации.