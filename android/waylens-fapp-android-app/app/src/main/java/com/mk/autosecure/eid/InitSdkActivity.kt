package com.mk.autosecure.eid

import android.annotation.SuppressLint
import android.content.Intent
import android.net.SSLCertificateSocketFactory
import android.os.Build
import android.os.Bundle
import android.os.Message
import android.provider.Settings
import android.provider.Settings.Secure
import android.provider.Settings.Secure.getString
import android.util.Log
import android.view.View
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import com.mk.autosecure.R
import com.nt.moc_lib.icao.SdkMoCIcao
import com.nt.moc_lib.icao.Utils.*
import com.orhanobut.logger.Logger
import kotlinx.android.synthetic.main.activity_register.*
import kotlinx.android.synthetic.main.activity_tcvn.*
import org.apache.http.conn.ssl.AllowAllHostnameVerifier
import org.json.JSONObject
import java.io.BufferedReader
import java.io.DataOutputStream
import java.io.IOException
import java.io.InputStreamReader
import java.net.MalformedURLException
import java.net.ProtocolException
import java.net.URL
import javax.net.ssl.HttpsURLConnection

class InitSdkActivity : AppCompatActivity(), SdkMoCIcao.ResultSdk {
    companion object {
        var TAG = InitSdkActivity().toString()
    }

    var providerSecret = "MKgroupX9KA3wMaNnDf8eowmnLd6qzX5"
    var serverLink = "https://192.168.0.195:15503/api/"
    var licenseLink = "https://192.168.0.195:8778/api/"
    var sdkMoCIcao: SdkMoCIcao? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_register)
        tv_toolbarTitle.text = getText(R.string.register_device)
        toolbar.setNavigationOnClickListener { finish() }
        sdkMoCIcao = SdkMoCIcao(this, providerSecret, serverLink, licenseLink)
        sdkMoCIcao!!.checkActivated()
        sdkMoCIcao!!.getDeviceInfo()
        findViewById<View>(R.id.btAc).setOnClickListener {
            sdkMoCIcao!!.active_eID("", "4", 4)
        }
    }

    override fun resultActive(code: String, message: String) {

        Log.d("resultActive:", code + "____" + message)

        when (code) {
            ACTIVATED -> {
                Toast.makeText(this, "actived!", Toast.LENGTH_SHORT).show()
                val intent = Intent(this, ReadCardActivity::class.java)
                startActivity(intent)
                finish()
            }
            NOT_ACTIVATED -> {

                Toast.makeText(this, "not actived!", Toast.LENGTH_SHORT).show()
            }
            EXPIRED_LICENSE -> {
                Toast.makeText(this, "expired_license", Toast.LENGTH_SHORT).show()
            }
            else -> {
                Toast.makeText(this, message + code, Toast.LENGTH_SHORT)
                    .show()
            }

        }

    }

    @SuppressLint("HardwareIds")
    override fun resultInfoDevice(infoDevice: String) {
        Logger.t(TAG).d("infoDevice==", infoDevice)
        tvId.text = getString(baseContext.contentResolver,Secure.ANDROID_ID).uppercase()
        tvName.text = Build.MODEL
        registerDeviceNew(infoDevice)
    }

    fun registerDeviceNew(dataInfo: String) {
        Logger.t(TAG).d("dataInfo==", dataInfo)
        Thread {
            var data = getRegister(dataInfo)
            Logger.t(TAG).d("data==", data)
            var jsonObject = JSONObject(data)
            var code = jsonObject.getInt("code")
            if (code == 0) {
                runOnUiThread {
                    Toast.makeText(this, "Đăng ký thiết bị thành công", Toast.LENGTH_SHORT).show()
                }
                Log.d("sig==", code.toString())
            } else {
                runOnUiThread {
                    Toast.makeText(this, "Đăng ký thiết bị thất bại $code", Toast.LENGTH_SHORT)
                        .show()
                }
                Log.d("sig==", code.toString())
            }

        }.start()
    }

    @SuppressLint("AllowAllHostnameVerifier", "SSLCertificateSocketFactoryGetInsecure")
    fun getRegister(body: String?): String? {
        val url = "https://192.168.0.195:15600/api/device-reg/registerDeviceV2"
        var con: HttpsURLConnection? = null
        return try {
            //                JSONObject jsonObject = new JSONObject();
            //                jsonObject.put("name", "Jack");
            //                jsonObject.put("salary", "3540");
            //                jsonObject.put("age", "23");

            // Convert JSONObject to String
            val myurl = URL(url)
            con = myurl.openConnection() as HttpsURLConnection
            con.sslSocketFactory = SSLCertificateSocketFactory.getInsecure(0, null);
            con.hostnameVerifier = AllowAllHostnameVerifier();
            con.doOutput = true
            con!!.requestMethod = "POST"
            con.setRequestProperty("Authorization", "Basic YXBpOmFwaXBhc3N3b3JkMQ==")
            con.setRequestProperty("Content-Type", "application/json")
            con.setRequestProperty("Accept", "application/json")
            val wr = DataOutputStream(con.outputStream)
            wr.writeBytes(body)
            val br = BufferedReader(InputStreamReader(con.inputStream))
            var line: String?
            val content: StringBuilder = StringBuilder()
            while (br.readLine().also { line = it } != null) {
                content.append(line)
            }
            content.toString()
        } catch (e: ProtocolException) {
            e.printStackTrace()
            e.toString()
        } catch (e: MalformedURLException) {
            e.printStackTrace()
            e.toString()
        } catch (e: IOException) {
            e.printStackTrace()
            e.toString()
        } finally {
            con!!.disconnect()
        }
    }

}