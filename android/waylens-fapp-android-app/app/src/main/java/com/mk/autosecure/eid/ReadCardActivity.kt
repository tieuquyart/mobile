package com.mk.autosecure.eid

import android.Manifest
import android.annotation.SuppressLint
import android.app.AlertDialog
import android.app.PendingIntent
import android.app.ProgressDialog
import android.content.DialogInterface
import android.content.Intent
import android.content.pm.PackageManager
import android.nfc.NfcAdapter
import android.nfc.Tag
import android.nfc.tech.IsoDep
import android.os.Bundle
import android.widget.Button
import android.widget.LinearLayout
import android.widget.ProgressBar
import android.widget.TextView
import android.widget.Toast
import androidx.appcompat.app.AppCompatActivity
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.mk.autosecure.R
import com.mk.autosecure.libs.utils.Constants
import com.mk.autosecure.ui.activity.LocalLiveActivity
import com.mkgroup.camera.preference.PreferenceUtils
import com.nt.moc_lib.icao.ReadCard
import com.nt.moc_lib.icao.ResultInfo
import kotlinx.android.synthetic.main.activity_tcvn.*
import java.util.*


class ReadCardActivity : AppCompatActivity(), ResultInfo {

    private val REQUEST_ID_MULTIPLE_PERMISSIONS = 1
    private val WARNING_PROCEED_WITH_NOT_GRANTED_PERMISSIONS =
        "Do you wish to proceed without granting all permissions?"
    private val WARNING_NOT_ALL_GRANTED = "Some permissions are not granted."
    private val MESSAGE_ALL_PERMISSIONS_GRANTED = "All permissions granted"
    private val mPermissions: MutableMap<String, Int> = HashMap()

    private fun showDialogOK(message: String, okListener: DialogInterface.OnClickListener) {
        AlertDialog.Builder(this)
            .setMessage(message)
            .setPositiveButton("OK", okListener)
            .setNegativeButton("Cancel", okListener)
            .create()
            .show()
    }

    private fun requestPermissions(permissions: Array<String>) {
        ActivityCompat.requestPermissions(
            this,
            permissions,
            REQUEST_ID_MULTIPLE_PERMISSIONS
        )
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<String>,
        grantResults: IntArray
    ) {
        when (requestCode) {
            REQUEST_ID_MULTIPLE_PERMISSIONS -> {

                // Initialize the map with permissions
                mPermissions.clear()
                // Fill with actual results from user
                if (grantResults.isNotEmpty()) {
                    var i = 0
                    while (i < permissions.size) {
                        mPermissions[permissions[i]] = grantResults[i]
                        i++
                    }
                    // Check if at least one is not granted
                    if (mPermissions[Manifest.permission.CAMERA] != PackageManager.PERMISSION_GRANTED
//                        || mPermissions[Manifest.permission.RECORD_AUDIO] != PackageManager.PERMISSION_GRANTED
//                        ||(mPermissions[Manifest.permission.WRITE_EXTERNAL_STORAGE] != PackageManager.PERMISSION_GRANTED
//                                && android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.TIRAMISU)
                    ) {
                        showDialogOK(
                            WARNING_PROCEED_WITH_NOT_GRANTED_PERMISSIONS
                        ) { _, which ->
                            when (which) {
                                DialogInterface.BUTTON_POSITIVE -> {
                                    for ((key, value) in mPermissions) {
                                        if (value != PackageManager.PERMISSION_GRANTED) {
                                            finish()
                                        }
                                    }

                                }
                                DialogInterface.BUTTON_NEGATIVE -> requestPermissions(
                                    permissions
                                )
                                else -> throw AssertionError("Unrecognised permission dialog parameter value")
                            }
                        }
                    } else {
                        readCard = ReadCard(this)
                        readCard!!.setCameraView(camView, textView)
                        readCard!!.showCameraView()
                    }
                }
            }
        }
    }

    private fun getNotGrantedPermissions(): Array<String>? {
        val neededPermissions: MutableList<String> = ArrayList()


        val cameraPermission =
            ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA)


        if (cameraPermission != PackageManager.PERMISSION_GRANTED) {
            neededPermissions.add(Manifest.permission.CAMERA)
        }



        return neededPermissions.toTypedArray()
    }

    var readCard: ReadCard? = null
    var camView: LinearLayout? = null
    var textView: TextView? = null

    var scan: Button? = null

    var progressDialog: ProgressDialog? = null


    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_read_card)
        camView = findViewById(R.id.cameraView)

        textView = findViewById(R.id.notifi)
        tv_toolbarTitle.text = getText(R.string.verify_face_title)
        toolbar.setNavigationOnClickListener { finish() }

        scan = findViewById(R.id.scan)

        progressDialog = ProgressDialog(this)
        progressDialog!!.setTitle(getString(R.string.waiting_process))
        progressDialog!!.setMessage(getString(R.string.loading_process))
        progressDialog!!.setCancelable(true)
        progressDialog!!.setOnCancelListener { readCard!!.showCameraView() }

        var neededPermissions: Array<String> = getNotGrantedPermissions()!!
        if (neededPermissions.isNotEmpty()) {
            requestPermissions(neededPermissions)
        } else {
            readCard = ReadCard(this)
            readCard!!.onSwitchLiveness(false) // check liveness
            readCard!!.setCameraView(camView, textView)
            readCard!!.showCameraView()
        }

        // bắt đầu extract face
        scan!!.setOnClickListener {
            readCard!!.startExtractFace()
        }
    }

    override fun onMoc(code: String, message: String) {
//        Toast.makeText(this, message, Toast.LENGTH_SHORT).show()
        progressDialog!!.dismiss()
        if (code == "0") {
            finish()
            PreferenceUtils.putBoolean(Constants.KEY_IS_LOGIN, true)
            LocalLiveActivity.launch(this, true)
        } else {
            readCard!!.showCameraView()
        }
    }

    var nfcCheck = false;

    override fun onExtractFace(code: String?, message: String?) {

        if (code == "0") {
            nfcCheck = true
            Toast.makeText(this, "extract " + message + "Sẵn sàng đọc thẻ", Toast.LENGTH_SHORT)
                .show()
            progressDialog!!.show()
        } else {
            nfcCheck = false
            if (progressDialog!!.isShowing) {
                progressDialog!!.dismiss()
            }
            // load lại camera view khi extract thất bại
            Toast.makeText(this, "extract $message", Toast.LENGTH_SHORT).show()

            readCard!!.showCameraView()
        }
    }

    var adapter: NfcAdapter? = null

    @SuppressLint("WrongConstant")
    override fun onResume() {
        super.onResume()

        adapter = NfcAdapter.getDefaultAdapter(this)
        if (adapter != null) {
            val intent = Intent(applicationContext, this.javaClass)
            intent.flags = Intent.FLAG_ACTIVITY_SINGLE_TOP
            var pendingIntent: PendingIntent? = null
            if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.S) {

                pendingIntent = PendingIntent.getActivity(
                    this,
                    0,
                    intent,
                    PendingIntent.FLAG_MUTABLE
                )

            } else {
                pendingIntent = PendingIntent.getActivity(
                    this,
                    0,
                    intent,
                    PendingIntent.FLAG_UPDATE_CURRENT
                )
            }

            val filter = arrayOf(arrayOf("android.nfc.tech.IsoDep"))
            adapter!!.enableForegroundDispatch(this, pendingIntent, null, filter)
        }
    }

    override fun onPause() {
        super.onPause()
        if (adapter != null) {
            adapter?.disableForegroundDispatch(this)
            adapter = null
        }
    }

    private var isoDep: IsoDep? = null

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)

        var a: String = intent.action.toString();
        if (NfcAdapter.ACTION_TECH_DISCOVERED == intent.action) {

            val tag = intent.extras!!.getParcelable<Tag>(NfcAdapter.EXTRA_TAG)

            if (listOf(*tag!!.techList).contains("android.nfc.tech.IsoDep")) {
                isoDep = IsoDep.get(tag)
                isoDep?.connect()
                isoDep?.timeout = 5000

                if (nfcCheck) {
                    progressDialog!!.show()
                    nfcCheck = false
                    // đọc thông tin thẻ
                    readCard?.readInfo(isoDep!!, "", 4, "", 4);
                }
            }
        }

    }

}