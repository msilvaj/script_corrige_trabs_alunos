#!/bin/bash
#####
#### O script recebe 3 parametros, o primeiro: o caminho dos arquivos, o segundo:
#### o arquivo de entrada, o terceiro: o arquivo de saida esperado.
#### assumindo que a maquina onde vai rodar tem os mecanismos de processamentos de 
#### C, C++, JAVA e PYTHON, nesta versão 1.0.
#### Ele vai buscar por um programa de acordo com a linguagem fonte deste, vai processar 
#### e gerar uma saida que vai ser utilizada para comparar as saidas. 
#### após isso, ele vai pedir uma nota. Como os arquivos dos alunos tem um determinado 
#### padrão, o script vai salvar a nota daquele programa em um arquivo chamado notas.txt, indicando neste
#### o nome do arquivo do aluno e a nota obtida.
#### Só para facilitar um pouco, o script mostra um texto em vermelho caso a saida do programa do aluno
#### esteja errada, e um texto verde caso esteja tudo certo.

ARG1=$1
ARG2=$2
ARG3=$3
LSDIR=`ls $ARG1`
cd $ARG1

trataDiff(){
	echo ""
#echo -e "Viva o \033[01;32mLinux\033[01;37m!"
	echo -e "\033[01;31mPrograma do Aluno produziu saida INCORRETA:\033[01;37m!"
	echo " "
	echo "Esperado:               		Produzido:"
	sdiff --tabsize=15 $ARG3 saidaProg.txt
	echo " "
	echo "Nota do aluno" $1": "		
	read NOTA
	echo $1 "--" $NOTA >> notas.txt

#	cat saidaDiff.txt
}

comparasaidas(){
#	md5sum $ARG3 saidaProg.txt > saidaMd5
	diff $ARG3 saidaProg.txt > saidaDiff.txt
	#caso haja diferenças no arquivo, a saida do diff vai ser algo nao nulo
	if [ -s saidaDiff.txt ]; then 
		trataDiff "$1"
	else	
		echo " "
		echo -e "\033[01;32mPrograma do Aluno produziu saida CORRETA:\033[01;37m!"
		#echo "Programa do aluno produziu saida CORRETA:"		
		echo " "
		echo "Esperado:               		Produzido:"
		sdiff --tabsize=15 $ARG3 saidaProg.txt 
		echo " "
		echo "Nota do aluno" $1": "		
		read NOTA
		echo $1 "--" $NOTA >> notas.txt
	fi
}

trataPython(){
#	echo "Executando tatamento de Arquivo Python"
#	echo $PFILE
	python $PFILE < $ARG2 > saidaProg.txt 
	if [ -s saidaDiff.txt ]; then
	rm saidaDiff.txt
	fi
	#neste ponto o script pegaria o nome do arquiv, que no caso tem os dados do aluno(matricula e nome)
	comparasaidas "$PFILE"
}

trataC(){
#	echo "Executando tatamento de Arquivo C"
	COUTPUT=`echo $CFILE | awk -F "." '{print $1}'`
	gcc $CFILE -o $COUTPUT && ./$COUTPUT < $ARQ2 > saidaProg.txt 
	comparasaidas "$CFILE"
}

trataCPP(){
#	echo "Executando tatamento de Arquivo C"
	CPPOUTPUT=`echo $CPPFILE | awk -F "." '{print $1}'`
	g++ $CPPFILE -o $CPPOUTPUT && ./$COUTPUT < $ARQ2 > saidaProg.txt 
	comparasaidas "$CPPFILE"
}

trataJava(){
#	echo "Executando tatamento de Arquivo JAVA"
	JOUTPUT=`echo $JFILE | awk -F "." '{print $1}'`
	javac $JFILE  && java $JOUTPUT < $ARG2 > saidaProg.txt 
	comparasaidas "$JFILE"
}

for i in $LSDIR
do 
#	CONT=`expr $CONT + 1`
	TIPO_ARQ=`echo $i | awk -F "." '{print $2}'`
	
	case $TIPO_ARQ in
		"py")	#echo "Python"
			if [ -s $i ]; then
			#apenas se o arquivo PYTHON tiver "main", ele vai ser executado
			GREPCOUNT=`grep "def main" $i | wc -l`
				if [ $GREPCOUNT -gt 0 ]; then
				PFILE=$i
				trataPython
				fi
			fi
			continue;;

		"c")	#echo $i 
			if [ -s $i ]; then
			#apenas se o arquivo C tiver "a função main", ele vai ser tratado
			GREPCOUNT=`grep "main" $i | wc -l`
				if [ $GREPCOUNT -gt 0 ]; then
				CFILE=$i
				trataC
				fi
			fi
			continue;;

		"cpp")	#echo Arquivo C++
			if [ -s $i ]; then
			#apenas se o arquivo C++ tiver "main", ele vai ser executado
			GREPCOUNT=`grep "main" $i | wc -l`
				if [ $GREPCOUNT -gt 0 ]; then
				CPPFILE=$i
				trataCPP
				fi
			fi
			continue;;
		"java")	#echo Arquivo JAVA
			if [ -s $i ]; then
			#apenas se o arquivo JAVA tiver "main", ele vai ser executado
			GREPCOUNT=`grep "main" $i | wc -l`
				if [ $GREPCOUNT -gt 0 ]; then
				JFILE=$i
				trataJava
				fi
			fi
			continue;;
	esac
done

