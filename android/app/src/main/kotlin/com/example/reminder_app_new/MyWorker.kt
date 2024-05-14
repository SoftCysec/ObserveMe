package com.example.reminder_app_new

import android.content.Context
import androidx.work.Worker
import androidx.work.WorkerParameters

class MyWorker(context: Context, workerParams: WorkerParameters) : Worker(context, workerParams) {

    override fun doWork(): Result {
        // Trigger the notification
        val reminderProvider = ReminderProvider()
        reminderProvider.triggerReminder()
        return Result.success()
    }
}
