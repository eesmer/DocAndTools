Backup-United readme
---
https://rsync.samba.org/tech_report/ <br>
https://rsync.samba.org/how-rsync-works.html

---

Backup United, başarılı yedekleme işlemleri yapmayı hedefler.<br>
Gerekli paketlerin kurulumu ile uygulamanın kullanımını tek bir script dosyası ile yapar.<br>
Bunlar için bir TUI sağlar. rsync, rdiff kullanır.<br>
Bu çalışma, aynı zamanda bir ders çalışma fırsatıdır.<br>

**Özellikler**
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

**Sorular, cevaplar - detaylar ve teknolojiler**<br>
**What is sync**<br>

---

**rsync notları**<br>
https://rsync.samba.org/ <br>
https://rsync.samba.org/tech_report/ <br>

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
<br>
**rdiff notları**<br>

