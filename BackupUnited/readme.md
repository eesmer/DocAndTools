Backup-United readme
---
https://rsync.samba.org/tech_report/ <br>
https://rsync.samba.org/how-rsync-works.html

---

Backup United, başarılı yedekleme işlemleri yapmayı hedefler.<br>
Gerekli paketlerin kurulumu ile uygulamanın kullanımını tek bir script dosyası ile yapar.<br>
Bunlar için bir TUI sağlar. rsync, rdiff kullanır.<br>
Bu çalışma, aynı zamanda bir ders çalışma fırsatıdır.<br>

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

**rsync**<br>
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
