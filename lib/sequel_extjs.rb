# Copyright (c) 2008 Galin Yordanov <gyordanov@gmail.com>, Nabbr Inc
# All rights reserved.
# 
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
#    notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
#    notice, this list of conditions and the following disclaimer in the
#    documentation and/or other materials provided with the distribution.
# 3. The name of the author may not be used to endorse or promote products
#    derived from this software without specific prior written permission.
# 
# THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
# IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
# OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
# IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
# NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
# DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
# THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
# (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
# THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

module Sequel
  module Plugins

    # This module will extend the regular Model to add few ExtJS related functions, mainly to_json and to_extjs
    #
    # Take a look at the Sequel::Plugins::ExtJS::DatasetMethods.to_extjs function
    module ExtJS

      def self.apply(model, *a)
      end

      module InstanceMethods

        # return a json hash from the current Model instance,
        # this will work even on joins and it will include all selected fields
        def to_json(*a)
         values.to_json(*a)
        end

        # Same as the dataset method, but it only works for single records (including ones that are not saved yet)
        def to_extjs()
          data = self
          if block_given?
            data = yield self
          end
          fields = data.keys.map{|a| {:name => a}}

          {
            :totalCount => 1,
            :metaData => {
              :totalProperty => 'totalCount',
              :root => 'result',
              :id => primary_key,
              :fields => fields
            },
            :result => [data]
          }.to_json
        end


      end

      module ClassMethods
        # this will return a properly formated ExtJS metaData hash for its JsonReader, keep in mind that it will only return
        # fields that beling to that model and wont honor joins (its a class method after all).
        # To include extra fields please pass a array with the name of the fields as a parameter
        def extjs_metadata(ary = [])
          (self.columns + ary).inject(""){|res,el| "#{res}{name : '#{el}'}," }
        end
      end

      module DatasetMethods
        # return a array of json hashes for the current dataset  (i.e. current query result with multiple records)
        def to_json
          map{|b| b.values}.to_json
        end

        # Generate everything ExtJS needs to display this dataset into a grid
        # you can overwrite the returned count (in case you are using pagination) by supplying it as a first parameter
        # this function also accepts a block that you can iterate over and modify the element (adding/removing keys) (more or less replicate map)
        # this should work just about any dataset (including joins and stuff)
        # For simple dataset to ExtJS use:
        #  MyModel.to_extjs # all records
        #  MyModel.filter(:type => 'primary').to_extjs # (only the ones with type 'primary')
        #
        # Using blocks:
        # This sample will return JSON structure that is the same as MyModel.to_extjs BUT with the added 'newkey' element for all records
        #   MyModel.to_extjs do |mymodel|
        #     mymodel[:newkey] = 'somethingelse'
        #     mymodel
        #   end
        #
        # To remove a column(s) you have 2 options
        #
        # 1) use MyModel.select(:id,:name).to_extjs - it will display only the selected fields OR
        #
        # 2) use blocks to do it
        #   MyModel.to_extjs do |swf|
        #     res = mymodel.values
        #     res[:newkey] = 'somethingelse'
        #     res.delete(:name)
        #     res
        #   end
        #
        def to_extjs(overwrite_count = nil)
          data = all
          return '{}' if data.size == 0
          unless overwrite_count
            overwrite_count = data.size
          end

          if block_given?
            data.map! {|rec| yield rec}
          end
          fields = data.first.keys.map{|a| {:name => a}}

          {
            :totalCount => overwrite_count,
            :metaData => {
              :totalProperty => 'totalCount',
              :root => 'result',
              :id => first.primary_key,
              :fields => fields
            },
            :result => data
          }.to_json
        end
      end

    end
  end
end
