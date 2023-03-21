import pandas as pd
df = pd.read_csv("https://raw.githubusercontent.com/Halegua/Tarefa_Analise/main/idade_t.csv")
#idi = []
#for _, r in df.iterrows():
#    a = r['Município'].split()
#    idi.append(a[0])
#df['ID']=idi
#df.to_csv('E:/idade_t.csv')
pib = pd.read_csv('E:/Analytica/Pib.csv', encoding="cp1252")
pib = pib.loc[pib['Ano'] == 2020]

pib = pib.rename(columns={"Código do Município":"ID",'Produto Interno Bruto, \na preços correntes\n(R$ 1.000)':"pib",
                          "Produto Interno Bruto per capita, \na preços correntes\n(R$ 1,00)":"pib_capita"})
l=[]
for _,r in pib.iterrows():
    a = int(str(r["ID"])[:-1])
    l.append(a)
pib["ID"]=l
idade = pd.read_csv('https://raw.githubusercontent.com/Halegua/Tarefa_Analise/main/idade_t.csv')
idade.drop(idade.tail(1).index,inplace=True)
idade['ID']=idade['ID'].astype(int)
total = pib.merge(idade, how='inner', on='ID')
total = total.drop(['Unnamed: 0'], axis=1)

covid = pd.read_csv("https://raw.githubusercontent.com/Halegua/Tarefa_Analise/main/Covid.csv")
covid = covid.rename(columns={"city_ibge_code":"ID"})

l=[]


for _,r in covid.iterrows():
    try:
        a = int(r["ID"])
        a = int(str(a)[:-1])
        l.append(a)
    except:
        l.append(0)
covid["ID"]=l

covid = covid.loc[covid['ID'] != 0]
total = total.merge(covid, how='inner', on='ID')

l=[]
m=[]
for _,r in total.iterrows():
    a = int(r["pib"].replace(",",""))
    b = float(r['pib_capita'].replace(",",""))
    l.append(a)
    m.append(b)
total["pib"] = l
total["pib_capita"]=m
total.to_csv("E:/Total_Covid.csv",index=False)

