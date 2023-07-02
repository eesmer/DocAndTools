## BackupUnited readme

Backup United, başarılı yedekleme işlemleri yapmayı hedefler.<br>
Gerekli paketlerin kurulumu ile uygulamanın kullanımını tek bir script dosyası ile yapar ve bunun için bir TUI sağlar.<br>

---

## Özellikler
- Ağ üzerindeki SMB paylaşım hedefinden yedekleme yapar.
- Birden fazla yedekleme işini yönetir.
- Yedekleme işlemi sonuçları için mail bildirim yapar.

**Daha neler olabilir?**<br>
Hayat bu, birçok şey olabilir. Savaşlar, depremler ve sürekli kandıran politikacı veya halklar..
Konumuz Backup United 'da neler olabilir? (:
Bu listeye bir ToDo list demesek de yapmak istediklerimiz veya yapmak istemeyi istediklerimiz diyebiliriz.
- FTP erişiminden backup
- DB Backup
- Full Server Backup
- VM Backup

---

![alt text](images/BackupUnited-Menu-2.png "BackupUnited TUI")

---

## Sorular, Cevaplar ve Çalışma Notları
### - What is sync / Backup vs Sync <br>
Önce backup işleminin tanımını yapalım;<br>
**Backup:** Bir alandan başka bir alana (disk, paylaşım, bulut) dosyaların kopyalanarak çoğaltılmasıdır.<br>
Genel olarak amaç; dosyaların birebir kopyasının farklı bir ortamda tutulması ve gerektiğinde bu ortamdan alınmasıdır.<br>
**Sync:** Sync, senkronize anlamına gelir ve bir alandaki dataların başka bir alanda backup işlemi gibi tutulmasıdır.<br>
Amaç; 2 ortamdaki dataların dosya sürümü, güncel değişiklik durumu gibi kulanım kaynaklı farklılıklarının olmamasıdır.<br>
Yani yedek alınan veya sync edilen alandaki dosyaların kaynak alandaki dosyalarla güncel olmasıdır.<br>
Buna göre; 2 alanda eşitleme ile dosya silme veya güncelleme işlemleri yapılarak ortamlar birbirinin aynısı olur.<br>
<br>
Backup veya sync kullanımı ihtiyaca göre belirlenmelidir.<br>
Eğer en az 2 alanı eşitlemek istiyor ve gereksiz olduğu için silinen dataları saklama istemiyorsanız sync kullanabilirsiniz.<br>
Eğer gerekli veya gereksiz silinen dosyaları saklamak istiyorsanız backup kullanmalısınız.<br>
<br>
Backup işlemi ile tekrar tekrar aynı dosyaları kopyalar ve her kopyladığı dosyanın saklanmasını garanti etmiş olursunuz.<br>
Sync ile kaynak ve hedef alanlar sadece eşitlenir. Dosya saklanması sync işleminin amacı değildir.<br>

## rsync notları
https://rsync.samba.org/tech_report/ <br>
https://rsync.samba.org/how-rsync-works.html

<br>

rsync, uzak ve yerel ortamlardan dosya kopyalama aracıdır.<br>
Kopyalama işlemini 1 kez yaptıktan sonra güncelleme davranışı ile çalışabilir ve eşitlenmiş dizinler oluşturur.<br>
rsync, client-server ve sender-receiver işlem ve rollerini çalıştırarak dosya eşitlemesi (sync) yapar.<br>
<br>
**client:** Sync edilecek (eşitlenecek) dosya veya dizinleri temsil eder.<br>
**server:** remote shell veya network socket bağlantısını başlatan ve kopyalama süreci yönetimini yapan taraftır.<br>
**sender:** Eşitleme-kopyalama işlemi için kaynak dosya veya dizinlere erişim yapan işlemdir.<br>
**receiver:** Eşitlenecek dosyaları alan ve diske yazan işlemdir.<br>
**remote shell:** Client ve Server arasında bağlantı sağlayan işlemdir.<br>
<br>
**Kopyalama süreci başladığında;**<br>
İlk olarak dosya listesi çıkarılır. Bu dosya listesinde; ownership, file/directory mode, permission, size bilgileri de yer alır.<br>
Yedekleme/Eşitleme işlemi için gönderici ve alıcı rolünde bir çift uç, remote shell bağlantısında rsync komutları çalışabilir halde bir ortam oluşmuş olur.<br>
Gönderici ve Alıcı rollerini alan uç makineler arası kopyalama işlemi birtakım kontrol ve sağlamalara tabidir.<br>
Bu kontrol ve sağlamalar ile;<br>
Dosya Listesi oluşturma ve Gönderici ile Alıcı arasındaki liste farkı veya rsync komutunda kullanılan parametrelere göre dosya oluşturma işlemleri yönetilir.<br>
**Örnek:**
Gönderici, Dosya Listesini alır.<br>
rsync komutunda, --delete parametresi kullanılmışsa Gönderici, önce kendi tarafında olmayan yerel dosyaları belirler ve bunları alıcıdan siler.<br>
Bu işlemin ardından kopyalama yapıldığında her iki uç eşitlenir.<br>
<br>
Alıcı, gönderici verisinden her dosya için okuma yapar.<br>
Buna göre; kendi yerel ortamındaki dosya/dizin oluşturma-yazma işlemlerini yapar.<br>
Kopyalama ile işletilen sync işlemi, kopyalama başlamadan önce oluşturulan Dizin Listesi ve bu Dizin Listesinin Gönderici ve Alıcı yerel ortamlarındaki<br>
karşılaştırmaları esasına göre yapılır.<br>
Bu kontrollere ek olarak; rsync komutundaki parametreler de sync işleminin nasıl tamamlanacağını belirler.<br>
rsync işleminde, Gönderici elindeki Dosya Listesi ile Alıcı taraftaki Dizin Ağacındaki dosyaları karşılaştırdığı için en yoğun işlem yapan roldür.<br>
Alıcı, Gönderici'den aldığı veri listesine göre kendi yereline yazma işlemini yapan taraf olur.<br>
<br>
Birçok kopyalama işlemi rsync' ye göre daha kontrollü ve sağlam olabilir.<br>
Çünkü kopyalama esnasında ağ trafiği durumu ve kopyalama işlemini etkileyecek faktörleri kontrol edebilir.<br>
Fakat bu kontroller, işlemin performansını olumsuz etkiler.<br>
rsync işlemi, bu kontroller yerine Dizin Listesi ve hedef-kaynak karşılaştırması ile kopyalama performansına odaklıdır.<br>
Sorunsuz bir ağ trafiği ortamında performanslı ve problemsiz çalışır.<br>

### rdiff notları
