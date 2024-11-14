<p align="center">
  <a href="https://github.com/bittencourtthulio/localcache4d/blob/main/assets/logo.fw.png">
    <img alt="router4d" src="https://github.com/bittencourtthulio/localcache4d/blob/main/assets/logo.fw.png">
  </a>  
</p>
<br>
<p align="center">
  <img src="https://img.shields.io/github/v/release/bittencourtthulio/localcache4d?style=flat-square">
  <img src="https://img.shields.io/github/stars/bittencourtthulio/localcache4d?style=flat-square">
  <img src="https://img.shields.io/github/forks/bittencourtthulio/localcache4d?style=flat-square">
  <img src="https://img.shields.io/github/contributors/bittencourtthulio/localcache4d?color=orange&style=flat-square">
  <img src="https://tokei.rs/b1/github/bittencourtthulio/localcache4d?color=red&category=lines">
  <img src="https://tokei.rs/b1/github/bittencourtthulio/localcache4d?color=green&category=code">
  <img src="https://tokei.rs/b1/github/bittencourtthulio/localcache4d?color=yellow&category=files">
</p>

# localcache4d

Struttura di chiavi e valori, per una cache temporanea o fissa nell'applicazione.

## ⚙️ installazione

* Delphi 10.4

* **Installazione manuale**:

   Aggiungere la seguente cartella al progetto *Project > Options > Resource Compiler > Directories and Conditionals > Include file search path*

```pascal
../localcache4d/src
```

* **Uses neccessaria**:
```pascal
LocalCache4D;
```

## ⚡️ Come utilizare il LocalCache4D

Il LocalCache4D lavora come Singleton, così basta aggiungere la uses neccessaria e e utilizare la stanza soto per avere accesso ai metodi.

```pascal
LocalCache
```

## Come carricare il database

Se non definito il nome al file quando si chiamata il metodo `LoadDatabase`, viene creato automaticamente il database con la stensione `.lc4` e con il nome dell'applicazione al interno della cartella do si trova il `.exe`.
Se vuoi creare in altra cartella dovrà essere informato il percorso intero.

```pascal
LocalCache.LoadDatabase('Percorso intero'); //Se non fornire il percorso crea il database nella stessa cartella dell'applicazione.
```

## Definire il database in memoria

Para setar um dado para o Cache é necessário antes informar a instancia que você deseja que ele seja salvo, a instancia é como se fosse a sua tabela e/ou collection e dentro dela irá conter os registros Chave e Valor, você pode setar quantas instancias desejar;

```pascal
 LocalCache.Instance('Nome da Instancia').SetItem('Chave', 'Valor');
 ```
 
 ## Buscar um Registro no Cache

```pascal
 LocalCache.Instance('Nome da Instancia').GetItem('Chave');
 ```
 
 ## Remover um Registro no Cache

```pascal
 LocalCache.Instance('Nome da Instancia').RemoveItem('Chave');
 ```
 
 ## Remover uma Instancia e todos os seus Registros

```pascal
 LocalCache.RemoveInstance('Nome da Instancia');
 ```
 
  ## Persistir o Cache no Disco Local

Você pode salvar os dados do Cache no Disco Local e carrega-los novamente a qualquer momento com o LoadDataBase, para persistir os dados você deve chamar o comando abaixo, caso você não passe nenhum parametro para o Método SaveToStorage ele irá criar o banco com a extensão .lc4 na mesma pasta do executavel da sua aplicação e com o mesmo nome dela.

```pascal
 LocalCache.SaveToStorage('Path do Banco');
 ```
 
 
