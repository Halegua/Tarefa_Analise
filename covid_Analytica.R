library(tidyverse)
tidyverse_packages()
library(dplyr)


df <- read.csv(file = 'E:/Covid2022/db_PainelRioCovid.csv')
#dados encontrados em:
#https://pcrj.maps.arcgis.com/sharing/rest/content/items/ae85fc84a9b244108d96c7072be4d3d3/data


df=df %>%
  select(bairro_resid_estadia, sexo, faixa_etaria,evolucao, raca_cor)
#A função acima seleciona apenas as colunas que são interessantes para a analise.
head(df)

df = df %>%
  mutate(faixa_etaria = case_when(endsWith(faixa_etaria,"0 a 9")~5,
                                  endsWith(faixa_etaria,"19")~15,
                                  endsWith(faixa_etaria,"29")~25,
                                  endsWith(faixa_etaria,"39")~35,
                                  endsWith(faixa_etaria,"49")~45,
                                  endsWith(faixa_etaria,"59")~55,
                                  endsWith(faixa_etaria,"69")~65,
                                  endsWith(faixa_etaria,"79")~75,
                                  endsWith(faixa_etaria,"89")~85,
                                  endsWith(faixa_etaria,"99")~95,
                                  endsWith(faixa_etaria,"100")~105))

# No arquivo original, as idades eram resumidas apenas em intervalos de 10 anos,
# Aqui nesta função, abreviamos cada intervalo para o valor central para facilitar a análise
# ex.: "Entre 10 e 19" se tornou 15, "Entre 20 e 29" se tornou 25, etc.
# Apesar de ser uma estimativa grosseira, acreditamos que isso não afetaria muito o trabalho.

df=na.omit(df)

write.csv(df,"E://DF.csv", row.names = FALSE)


# Removemos os missing values porque eles gerariam problemas na nossa análise
# O df tinha 596116 e passou a ter 592591. Uma redução de menos de 1% da base de dados.
# Por ser uma quantidade pequena, não acreditamos que isso gerará um impacto significativo na análise. 


df_idade=df %>%
  group_by(faixa_etaria)%>%
  summarise(n=n(),obito=sum(evolucao=="óbito"),mortalidade=obito*100/n)

ggplot(df_idade, aes(x=faixa_etaria, y=mortalidade))+ geom_point()+geom_smooth() 
cor(df_idade$mortalidade,df_idade$faixa_etaria)

# Aqui há um gráfico de dispersão entre a faixa etária dos contaminados e a taxa de mortalidade
# A correlação calculada foi de 0.89

ggplot(data=df_idade, aes(x=faixa_etaria)) +
  geom_bar(aes(y=n), stat="identity", position ="identity", alpha=.3, fill='lightblue', color='lightblue4') +
  geom_bar(aes(y=obito), stat="identity", position="identity", alpha=.8, fill='pink', color='red')

#Uma outra maneira de visualizar a mortalidade x idade
#Perceba que apesar de mesmo havendo menos contaminados em idades mais avançadas, há maior observação de óbitos.


df_gr=df %>%
  group_by(bairro_resid_estadia)%>%
  summarise(n=n(),obito=sum(evolucao=="óbito"),mortalidade=obito*100/n,mean_idade=mean(faixa_etaria))%>%
  filter(n>130)


# Nesta função cria-se um novo dataframe, agrupado por bairros.
# Com a a qntde de contaminados, óbitos, taxa de mortalidade, e média de idade por bairros.
#Também foi filtrados os bairros com menos de 130 contaminados (4 bairros totalizando aprox. 200 pessoas;)



ggplot(df_gr, aes(x=mean_idade, y=mortalidade))+ geom_point()+geom_smooth() 
cor(df_gr$mortalidade,df_gr$mean_idade)


#Neste caso a correlação entre idade e mortalidade cai bastante (0.41)
#Perceba o  que acontece no polinômio de regressão nos bairros onde há maior população idosa - Por que isso acontece?

#Utilizamos os dados do Instituto Pereira Passos para adicionar uma nova coluna a esse DF: Renda Per Capita dos bairros do Rio
#Esses dados podem ser obtidos em: https://www.data.rio/documents/0d39554baf804dbdb1581f018781ccd0/about
#O novo dataframe pode ser obtido em: https://raw.githubusercontent.com/Halegua/AED_2022/main/Per_Capita.csv

renda=read.csv("https://raw.githubusercontent.com/Halegua/Covid_2022/main/Per_Capita.csv")
head(renda)

renda =na.omit(renda)
renda <- within(renda, classe_r <- as.integer(cut(Renda_Bairro, quantile(Renda_Bairro, probs=0:4/4), include.lowest=TRUE)))
#Aqui criamos uma nova classe, baseada em qual quartil a renda per capita de cada bairro se encontra.
#Sendo assim, é uma nova classificação de renda que compara aos demais bairros de forma mais compacta.

renda=renda %>%
  mutate(
    classe_S=ifelse(Renda_Bairro<2*510,"E", ifelse(Renda_Bairro<4*510,"D", ifelse(Renda_Bairro<10*510,"C",ifelse(Renda_Bairro<20*510,"B","A"))))
  )
Classe_S<-renda$classe_S
barplot(table(Classe_S),col=rgb(0.2,0.2,0.6,0.6))

#Aqui resolvemos criar também uma classe de acordo com o salário mínimo da época, sem comparar com os demais bairros.

ggplot(renda, aes(x=mean_idade, y=mortalidade))+ geom_smooth(aes(color=classe_S), method="lm")+ geom_point(aes(color=classe_S))
ggplot(renda, aes(x=mean_idade, y=mortalidade))+ geom_smooth()+ geom_point(aes(color=classe_S))

ggplot(renda, aes(x=mean_idade, y=mortalidade,color=classe_r))+ geom_smooth()+ geom_point()

data_renda_E<- renda[renda$classe_S=="E",]
ggplot(data_renda_E, aes(x=mean_idade, y=mortalidade))+ geom_point()+geom_smooth()
cor(data_renda_E$mortalidade,data_renda_E$mean_idade)

data_renda_D<- renda[renda$classe_S=="D",]
cor(data_renda_D$mortalidade,data_renda_D$mean_idade)

data_renda_C<- renda[renda$classe_S=="C",]
cor(data_renda_C$mortalidade,data_renda_C$mean_idade)

data_renda_B<- renda[renda$classe_S=="B",]
cor(data_renda_B$mortalidade,data_renda_B$mean_idade)


