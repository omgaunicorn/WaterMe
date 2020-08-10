//
//  LambdaIndex.js
//  WaterMe
//
//  Created by Jeffrey Bergier on 2020/08/10.
//  Copyright © 2020 Saturday Apps.
//
//  This file is part of WaterMe.  Simple Plant Watering Reminders for iOS.
//
//  WaterMe is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  WaterMe is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with WaterMe.  If not, see <http://www.gnu.org/licenses/>.
//

const crypto = require('crypto');
const aws = require('aws-sdk');
const ses = new aws.SES({region: 'us-east-2'});
const kSecretKey = process.env.SECRET;
const kEmailFrom = process.env.EMAIL_FROM;
const kEmailTo   = process.env.EMAIL_TO;

exports.handler = async (event, context, callback) => {
  // check environment variable
  if (!(typeof kSecretKey === 'string'
     && typeof kEmailFrom === 'string'
     && typeof kEmailTo   === 'string'))
  {
    return { statusCode: 403, body:'' };
  }
  // check make sure request is right
  if (event.requestContext.http.method != "PUT") {
    return { statusCode: 403, body:'' };
  }
  if (event.requestContext.http.path != "/log.cgi") {
    return { statusCode: 403, body:'' };
  }
  if (!('mac' in event.queryStringParameters)) {
    return { statusCode: 403, body:'' };
  }

  try {
    // do HMAC signature verification
    const secretKey_buffer = Buffer.from(kSecretKey, 'base64');
    const data_request = Buffer.from(event.body, 'base64');
    const signature_calculated = crypto
                                   .createHmac('sha256', secretKey_buffer)
                                   .update(data_request)
                                   .digest();
    const signature_calculated_base64 = Buffer.from(signature_calculated, 'binary').toString('base64');
    const signature_request_base64 = event.queryStringParameters.mac.replace(' ', '+');
    const signature_match = signature_request_base64 == signature_calculated_base64;
    if (!signature_match) {
      return { statusCode: 403, body:'' };
    }

    // send email
    const params = { Destination: { ToAddresses: [kEmailTo] },
                     Message: { Body: { Text: { Data: "" } },
                                Subject: { Data: "[" + signature_calculated_base64 + "] SUCCESS" } },
                     Source: kEmailFrom };

    const request = ses.sendEmail(params);
    await request.promise()
    return { statusCode: 200, body:'SUCCESS' };
  }
  catch(error) {
    return { statusCode: 403, body:'' };
    // debugging
    // return { statusCode: 400, body:error.message };
  }
  // Debugging
  // return { statusCode: 400, body:JSON.stringify(event) };
};

