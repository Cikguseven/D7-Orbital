import requests

backslash_char = "\\"

with open('labels1.txt', encoding="utf8") as data:
  for line in data:
    nutritionixURL = 'https://trackapi.nutritionix.com/v2/natural/nutrients'
    myobj = {'query': line}
    Nitem = requests.post(nutritionixURL, json = myobj, headers = {'Content-Type': 'application/json',
      'x-app-id': '08d04291',
      'x-app-key': 'e3896066f310654adb3e557e7c0d97f2'}).json()
    if (Nitem.get('message') == 'usage limits exceeded'):
      break
    if ("message" not in Nitem):
      print("FoodData(")
      print('name: "{0}",'.format(line.replace('\n', '')))
      print(f"\tenergy: {round(Nitem.get('foods')[0].get('nf_calories'))},")
      print(f"\tprotein: {Nitem.get('foods')[0].get('nf_protein')},")
      print(f"\tfats: {Nitem.get('foods')[0].get('nf_total_fat')},")
      print(f"\tcarbs: {Nitem.get('foods')[0].get('nf_total_carbohydrate')},")
      print(f"\tsugar: {Nitem.get('foods')[0].get('nf_sugars')}),")

print()
print('done')


# line = 'katsudon'
# url = 'https://trackapi.nutritionix.com/v2/natural/nutrients'
# myobj = {'query': line}
# x = requests.post(url, json = myobj, headers = {'Content-Type': 'application/json',
#   'x-app-id': 'f796dc25',
#   'x-app-key': '4947e3384d1affec1d4da58b428bd1e7'})
# print("FoodData(")
# print(f"\tname: '{line}',")
# print(f"\tenergy: {round(x.json().get('foods')[0].get('nf_calories'))},")
# print(f"\tprotein: {x.json().get('foods')[0].get('nf_protein')},")
# print(f"\tfats: {x.json().get('foods')[0].get('nf_total_fat')},")
# print(f"\tcarbs: {x.json().get('foods')[0].get('nf_total_carbohydrate')},")
# print(f"\tsugar: {x.json().get('foods')[0].get('nf_sugars')},")
# print("),")
# print()